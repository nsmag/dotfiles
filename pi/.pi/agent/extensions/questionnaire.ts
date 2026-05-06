/**
 * Questionnaire Extension
 *
 * Registers a `questionnaire` tool the LLM can call whenever it needs to
 * clarify requirements, gather preferences, or confirm decisions before
 * proceeding. Supports:
 *
 * - Single question  → simple numbered option list
 * - Multiple questions → tab-bar with per-question state and a Submit tab
 * - "Type something" free-text fallback on every question
 * - Escape to cancel at any time; Escape inside editor returns to options
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import {
	Editor,
	type EditorTheme,
	Key,
	matchesKey,
	Text,
	truncateToWidth,
	wrapTextWithAnsi,
} from "@mariozechner/pi-tui";
import { Type } from "typebox";

// ─── Domain types ────────────────────────────────────────────────────────────

interface QuestionOption {
	value: string;
	label: string;
	description?: string;
}

type RenderOption = QuestionOption & { isOther?: boolean };

interface Question {
	id: string;
	label: string;
	prompt: string;
	options: QuestionOption[];
	allowOther: boolean;
}

interface Answer {
	id: string;
	value: string;
	label: string;
	wasCustom: boolean;
	index?: number;
}

interface QuestionnaireResult {
	questions: Question[];
	answers: Answer[];
	cancelled: boolean;
}

// ─── Parameter schemas ───────────────────────────────────────────────────────

const QuestionOptionSchema = Type.Object({
	value: Type.String({ description: "Value returned when this option is selected" }),
	label: Type.String({ description: "Display label for the option" }),
	description: Type.Optional(
		Type.String({ description: "Optional clarifying description shown below the label" }),
	),
});

const QuestionSchema = Type.Object({
	id: Type.String({ description: "Unique identifier for this question (used in the answer map)" }),
	label: Type.Optional(
		Type.String({
			description:
				"Short label shown in the tab bar, e.g. 'Scope', 'Priority'. Defaults to Q1, Q2, …",
		}),
	),
	prompt: Type.String({ description: "Full question text shown to the user" }),
	options: Type.Array(QuestionOptionSchema, { description: "Options the user may choose from" }),
	allowOther: Type.Optional(
		Type.Boolean({ description: "Allow a free-text 'Type something' option (default: true)" }),
	),
});

const QuestionnaireParams = Type.Object({
	questions: Type.Array(QuestionSchema, {
		description: "One or more questions to present. Use multiple questions in a single call rather than calling this tool repeatedly.",
	}),
});

// ─── Helper ──────────────────────────────────────────────────────────────────

function errorResult(
	message: string,
	questions: Question[] = [],
): { content: { type: "text"; text: string }[]; details: QuestionnaireResult } {
	return {
		content: [{ type: "text", text: message }],
		details: { questions, answers: [], cancelled: true },
	};
}

// ─── Extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "questionnaire",
		label: "Questionnaire",
		description:
			"Ask the user one or more questions to clarify requirements, gather preferences, or confirm decisions. " +
			"For a single question a simple option list is shown; for multiple questions a tab-based interface lets the user navigate freely before submitting. " +
			"Always batch related questions into one call instead of calling this tool multiple times.",
		promptSnippet: "Clarify requirements or gather preferences from the user",
		promptGuidelines: [
			"Use questionnaire when the user's request is ambiguous or missing key details needed to proceed.",
			"Batch all related questions into a single questionnaire call rather than asking one at a time.",
		],
		parameters: QuestionnaireParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!ctx.hasUI) {
				return errorResult("Error: UI not available (running in non-interactive mode)");
			}
			if (params.questions.length === 0) {
				return errorResult("Error: No questions provided");
			}

			// Normalise questions – fill defaults
			const questions: Question[] = params.questions.map((q, i) => ({
				...q,
				label: q.label ?? `Q${i + 1}`,
				allowOther: q.allowOther !== false,
			}));

			const isMulti = questions.length > 1;
			const totalTabs = questions.length + 1; // question tabs + Submit tab

			const result = await ctx.ui.custom<QuestionnaireResult>((tui, theme, _kb, done) => {
				// ── State ──────────────────────────────────────────────────
				let currentTab = 0;
				let optionIndex = 0;
				let inputMode = false;
				let inputQuestionId: string | null = null;
				let cachedLines: string[] | undefined;
				const answers = new Map<string, Answer>();

				// ── Editor (free-text "Type something") ───────────────────
				const editorTheme: EditorTheme = {
					borderColor: (s) => theme.fg("accent", s),
					selectList: {
						selectedPrefix: (t) => theme.fg("accent", t),
						selectedText: (t) => theme.fg("accent", t),
						description: (t) => theme.fg("muted", t),
						scrollInfo: (t) => theme.fg("dim", t),
						noMatch: (t) => theme.fg("warning", t),
					},
				};
				const editor = new Editor(tui, editorTheme);

				editor.onSubmit = (value) => {
					if (!inputQuestionId) return;
					const trimmed = value.trim() || "(no response)";
					saveAnswer(inputQuestionId, trimmed, trimmed, true);
					inputMode = false;
					inputQuestionId = null;
					editor.setText("");
					advanceAfterAnswer();
				};

				// ── Helpers ────────────────────────────────────────────────
				function refresh() {
					cachedLines = undefined;
					tui.requestRender();
				}

				function submit(cancelled: boolean) {
					done({ questions, answers: Array.from(answers.values()), cancelled });
				}

				function currentQuestion(): Question | undefined {
					return questions[currentTab];
				}

				function currentOptions(): RenderOption[] {
					const q = currentQuestion();
					if (!q) return [];
					const opts: RenderOption[] = [...q.options];
					if (q.allowOther) {
						opts.push({ value: "__other__", label: "Type something.", isOther: true });
					}
					return opts;
				}

				function allAnswered(): boolean {
					return questions.every((q) => answers.has(q.id));
				}

				function saveAnswer(
					questionId: string,
					value: string,
					label: string,
					wasCustom: boolean,
					index?: number,
				) {
					answers.set(questionId, { id: questionId, value, label, wasCustom, index });
				}

				function advanceAfterAnswer() {
					if (!isMulti) {
						submit(false);
						return;
					}
					if (currentTab < questions.length - 1) {
						currentTab++;
					} else {
						currentTab = questions.length; // go to Submit tab
					}
					optionIndex = 0;
					refresh();
				}

				// ── Input handling ─────────────────────────────────────────
				function handleInput(data: string) {
					// While in free-text input mode, route everything to the editor
					if (inputMode) {
						if (matchesKey(data, Key.escape)) {
							inputMode = false;
							inputQuestionId = null;
							editor.setText("");
							refresh();
							return;
						}
						editor.handleInput(data);
						refresh();
						return;
					}

					const opts = currentOptions();

					// Tab / arrow navigation across question tabs (multi only)
					if (isMulti) {
						if (matchesKey(data, Key.tab) || matchesKey(data, Key.right)) {
							currentTab = (currentTab + 1) % totalTabs;
							optionIndex = 0;
							refresh();
							return;
						}
						if (matchesKey(data, Key.shift("tab")) || matchesKey(data, Key.left)) {
							currentTab = (currentTab - 1 + totalTabs) % totalTabs;
							optionIndex = 0;
							refresh();
							return;
						}
					}

					// Submit tab
					if (currentTab === questions.length) {
						if (matchesKey(data, Key.enter) && allAnswered()) {
							submit(false);
						} else if (matchesKey(data, Key.escape)) {
							submit(true);
						}
						return;
					}

					// Option list navigation
					if (matchesKey(data, Key.up)) {
						optionIndex = Math.max(0, optionIndex - 1);
						refresh();
						return;
					}
					if (matchesKey(data, Key.down)) {
						optionIndex = Math.min(opts.length - 1, optionIndex + 1);
						refresh();
						return;
					}

					// Select highlighted option
					if (matchesKey(data, Key.enter)) {
						const q = currentQuestion();
						const opt = opts[optionIndex];
						if (!q || !opt) return;

						if (opt.isOther) {
							inputMode = true;
							inputQuestionId = q.id;
							editor.setText("");
							refresh();
							return;
						}
						saveAnswer(q.id, opt.value, opt.label, false, optionIndex + 1);
						advanceAfterAnswer();
						return;
					}

					// Cancel everything
					if (matchesKey(data, Key.escape)) {
						submit(true);
					}
				}

				// ── Renderer ───────────────────────────────────────────────
				function render(width: number): string[] {
					if (cachedLines) return cachedLines;

					const lines: string[] = [];
					const add = (s: string) => lines.push(truncateToWidth(s, width));
					const addWrapped = (s: string) => {
						for (const line of wrapTextWithAnsi(s, width)) lines.push(line);
					};

					add(theme.fg("accent", "─".repeat(width)));

					// Tab bar (multi-question mode only)
					if (isMulti) {
						const parts: string[] = ["← "];
						for (let i = 0; i < questions.length; i++) {
							const active = i === currentTab;
							const answered = answers.has(questions[i].id);
							const box = answered ? "■" : "□";
							const color = answered ? "success" : "muted";
							const text = ` ${box} ${questions[i].label} `;
							const styled = active
								? theme.bg("selectedBg", theme.fg("text", text))
								: theme.fg(color, text);
							parts.push(`${styled} `);
						}
						const canSubmit = allAnswered();
						const onSubmit = currentTab === questions.length;
						const submitText = " ✓ Submit ";
						const submitStyled = onSubmit
							? theme.bg("selectedBg", theme.fg("text", submitText))
							: theme.fg(canSubmit ? "success" : "dim", submitText);
						parts.push(`${submitStyled} →`);
						add(` ${parts.join("")}`);
						lines.push("");
					}

					const q = currentQuestion();
					const opts = currentOptions();

					function renderOptions() {
						for (let i = 0; i < opts.length; i++) {
							const opt = opts[i];
							const selected = i === optionIndex;
							const isOther = opt.isOther === true;
							const prefix = selected ? "> " : "  ";
							const numStr = `${i + 1}. `;
							// Indent for continuation lines of the label (align past "> N. ")
							const labelIndent = " ".repeat(prefix.length + numStr.length);
							const color = selected ? "accent" : "text";

							if (isOther && inputMode) {
								add(
									theme.fg("accent", prefix) +
										theme.fg("accent", `${numStr}${opt.label} ✎`),
								);
							} else {
								const labelLines = wrapTextWithAnsi(
									theme.fg(color, `${numStr}${opt.label}`),
									width - prefix.length,
								);
								for (let li = 0; li < labelLines.length; li++) {
									const linePrefix = li === 0 ? theme.fg(color, prefix) : labelIndent;
									lines.push(truncateToWidth(linePrefix + labelLines[li], width));
								}
							}
							if (opt.description) {
								// Indent descriptions to align under the label text
								const descIndent = " ".repeat(prefix.length + numStr.length);
								const descLines = wrapTextWithAnsi(
									theme.fg("muted", opt.description),
									width - descIndent.length,
								);
								for (const descLine of descLines) lines.push(descIndent + descLine);
							}
						}
					}

					if (inputMode && q) {
						// Show question + options for reference, then the editor
						addWrapped(theme.fg("text", ` ${q.prompt}`));
						lines.push("");
						renderOptions();
						lines.push("");
						add(theme.fg("muted", " Your answer:"));
						for (const line of editor.render(width - 2)) {
							add(` ${line}`);
						}
						lines.push("");
						add(theme.fg("dim", " Enter to submit • Esc to go back"));
					} else if (currentTab === questions.length) {
						// Submit review tab
						add(theme.fg("accent", theme.bold(" Ready to submit")));
						lines.push("");
						for (const question of questions) {
							const answer = answers.get(question.id);
							if (answer) {
								const prefix = answer.wasCustom ? "(wrote) " : "";
								add(
									`${theme.fg("muted", ` ${question.label}: `)}${theme.fg("text", prefix + answer.label)}`,
								);
							} else {
								add(
									`${theme.fg("muted", ` ${question.label}: `)}${theme.fg("warning", "unanswered")}`,
								);
							}
						}
						lines.push("");
						if (allAnswered()) {
							add(theme.fg("success", " Press Enter to submit"));
						} else {
							const missing = questions
								.filter((q) => !answers.has(q.id))
								.map((q) => q.label)
								.join(", ");
							add(theme.fg("warning", ` Still unanswered: ${missing}`));
						}
					} else if (q) {
						// Normal question tab
						addWrapped(theme.fg("text", ` ${q.prompt}`));
						lines.push("");
						renderOptions();
					}

					lines.push("");

					if (!inputMode) {
						const help = isMulti
							? " Tab/←→ switch question • ↑↓ navigate • Enter select • Esc cancel"
							: " ↑↓ navigate • Enter select • Esc cancel";
						add(theme.fg("dim", help));
					}

					add(theme.fg("accent", "─".repeat(width)));

					cachedLines = lines;
					return lines;
				}

				return {
					render,
					invalidate: () => {
						cachedLines = undefined;
					},
					handleInput,
				};
			});

			// ── Build tool result ────────────────────────────────────────
			if (result.cancelled) {
				return {
					content: [{ type: "text", text: "User cancelled the questionnaire." }],
					details: result,
				};
			}

			const answerLines = result.answers.map((a) => {
				const qLabel = questions.find((q) => q.id === a.id)?.label ?? a.id;
				return a.wasCustom
					? `${qLabel}: user wrote: ${a.value}`
					: `${qLabel}: user selected: ${a.index}. ${a.label}`;
			});

			return {
				content: [{ type: "text", text: answerLines.join("\n") }],
				details: result,
			};
		},

		// ── TUI renderers ────────────────────────────────────────────────────

		renderCall(args, theme, _context) {
			const qs = (args.questions as Question[]) ?? [];
			const count = qs.length;
			const labels = qs.map((q) => q.label || q.id).join(", ");
			let text = theme.fg("toolTitle", theme.bold("questionnaire "));
			text += theme.fg("muted", `${count} question${count !== 1 ? "s" : ""}`);
			if (labels) text += theme.fg("dim", ` (${truncateToWidth(labels, 40)})`);
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme, _context) {
			const details = result.details as QuestionnaireResult | undefined;
			if (!details) {
				const first = result.content[0];
				return new Text(first?.type === "text" ? first.text : "", 0, 0);
			}
			if (details.cancelled) {
				return new Text(theme.fg("warning", "Cancelled"), 0, 0);
			}
			const lines = details.answers.map((a) => {
				const prefix = theme.fg("success", "✓ ") + theme.fg("accent", `${a.id}: `);
				if (a.wasCustom) {
					return prefix + theme.fg("muted", "(wrote) ") + a.value;
				}
				const display = a.index != null ? `${a.index}. ${a.label}` : a.label;
				return prefix + display;
			});
			return new Text(lines.join("\n"), 0, 0);
		},
	});
}
