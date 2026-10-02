import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Editor, Key, matchesKey, SelectList, Text, truncateToWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";
import { type Static, Type } from "typebox";

const OptionSchema = Type.Object({
	value: Type.String({ minLength: 1, description: "Stable value returned when selected" }),
	label: Type.String({ minLength: 1, description: "Display label for this choice" }),
	description: Type.Optional(Type.String({ description: "Brief explanation or trade-off" })),
});

const QuestionSchema = Type.Object({
	id: Type.String({ minLength: 1, description: "Unique question identifier" }),
	label: Type.Optional(Type.String({ minLength: 1, description: "Short tab label, e.g. Scope or Approach" })),
	prompt: Type.String({ minLength: 1, description: "The question to ask the user" }),
	options: Type.Array(OptionSchema, { minItems: 1, description: "Single-choice options with unique values" }),
	recommendation: Type.Optional(
		Type.Object({
			value: Type.String({ minLength: 1, description: "Value of the recommended option; must match an option" }),
			reason: Type.String({ minLength: 1, description: "Why this option is recommended for the user's situation" }),
		}),
	),
	allowOther: Type.Optional(Type.Boolean({ description: "Allow a free-form Other answer (default: true)" })),
});

const QuestionnaireParams = Type.Object({
	questions: Type.Array(QuestionSchema, { minItems: 1, description: "One or more questions to ask together" }),
});

const AnswerSchema = Type.Object({
	id: Type.String(),
	value: Type.String(),
	label: Type.String(),
	wasCustom: Type.Boolean(),
	wasRecommended: Type.Boolean(),
});

const ResultSchema = Type.Object({
	questions: Type.Array(QuestionSchema),
	answers: Type.Array(AnswerSchema),
	cancelled: Type.Boolean(),
});

type QuestionInput = Static<typeof QuestionSchema>;
type Question = QuestionInput & { label: string; allowOther: boolean };
type Answer = Static<typeof AnswerSchema>;
type Result = Static<typeof ResultSchema>;

function normalizeQuestions(inputs: QuestionInput[]): Question[] {
	if (!inputs.length) throw new Error("Provide at least one question.");
	const ids = new Set<string>();
	return inputs.map((question, index) => {
		if (!question.id.trim() || ids.has(question.id)) {
			throw new Error(`Question IDs must be non-empty and unique: ${JSON.stringify(question.id)}`);
		}
		ids.add(question.id);
		if (!question.prompt.trim() || (question.label !== undefined && !question.label.trim())) {
			throw new Error(`Question ${question.id} has an empty prompt or label.`);
		}
		if (!question.options.length) throw new Error(`Question ${question.id} needs at least one choice.`);
		const values = new Set<string>();
		for (const option of question.options) {
			if (!option.value.trim() || !option.label.trim() || values.has(option.value)) {
				throw new Error(`Question ${question.id} needs non-empty labels and unique, non-empty option values.`);
			}
			values.add(option.value);
		}
		if (question.recommendation) {
			if (!values.has(question.recommendation.value) || !question.recommendation.reason.trim()) {
				throw new Error(`Question ${question.id} needs a recommendation matching an option and a non-empty reason.`);
			}
		}
		return { ...question, label: question.label ?? `Q${index + 1}`, allowOther: question.allowOther !== false };
	});
}

function choiceAnswer(question: Question, index: number): Answer {
	const option = question.options[index];
	return {
		id: question.id,
		value: option.value,
		label: option.label,
		wasCustom: false,
		wasRecommended: question.recommendation?.value === option.value,
	};
}

function customAnswer(question: Question, text: string): Answer {
	return { id: question.id, value: text, label: text, wasCustom: true, wasRecommended: false };
}

function resultText(result: Result): string {
	return result.cancelled
		? "User cancelled the questionnaire. No answers were submitted; do not treat recommendations or drafts as decisions."
		: `User submitted these answers:\n${JSON.stringify(result.answers, null, 2)}`;
}

async function askQuestions(inputs: QuestionInput[], ctx: ExtensionContext, signal?: AbortSignal): Promise<Result> {
	const questions = normalizeQuestions(inputs);
	const cancelled = (): Result => ({ questions, answers: [], cancelled: true });
	if (!ctx.hasUI || (ctx.mode !== "tui" && ctx.mode !== "rpc")) {
		throw new Error("Questionnaire requires interactive or RPC UI. Ask the user in plain text instead; do not choose for them.");
	}
	if (signal?.aborted) return cancelled();

	// RPC clients support standard dialogs, but not custom terminal components.
	if (ctx.mode === "rpc") {
		const answers: Answer[] = [];
		for (const [index, question] of questions.entries()) {
			let title = `Question ${index + 1}/${questions.length}: ${question.prompt}`;
			if (question.recommendation) {
				const option = question.options.find((item) => item.value === question.recommendation!.value)!;
				title += `\nRecommended: ${option.label}\nWhy: ${question.recommendation.reason}`;
			}
			const choices = question.options.map((option, i) => {
				const badge = option.value === question.recommendation?.value ? " [recommended]" : "";
				return `${i + 1}. ${option.label}${badge}${option.description ? ` — ${option.description}` : ""}`;
			});
			if (question.allowOther) choices.push(`${choices.length + 1}. Other — type your answer`);
			const selected = await ctx.ui.select(title, choices, { signal });
			if (selected === undefined || signal?.aborted) return cancelled();
			const selectedIndex = choices.indexOf(selected);
			if (selectedIndex < 0) throw new Error("The UI returned an unknown questionnaire choice.");
			if (selectedIndex < question.options.length) {
				answers.push(choiceAnswer(question, selectedIndex));
			} else {
				while (true) {
					const text = await ctx.ui.input(question.prompt, "Type your answer", { signal });
					if (text === undefined || signal?.aborted) return cancelled();
					if (text.trim()) {
						answers.push(customAnswer(question, text.trim()));
						break;
					}
					ctx.ui.notify("Please enter a non-empty answer.", "warning");
				}
			}
		}
		if (questions.length > 1) {
			const summary = answers.map((answer, i) => `${questions[i].label}: ${answer.label}`).join("\n");
			if (!(await ctx.ui.confirm("Submit questionnaire?", summary, { signal }))) return cancelled();
		}
		return signal?.aborted ? cancelled() : { questions, answers, cancelled: false };
	}

	return ctx.ui.custom<Result>((tui, theme, keybindings, done) => {
		let currentTab = 0;
		let inputMode = false;
		let focused = false;
		let closed = false;
		let inputError = "";
		const answers = new Map<string, Answer>();
		const drafts = new Map<string, string>();
		const refresh = () => tui.requestRender();
		const selectTheme = {
			selectedPrefix: (text: string) => theme.fg("accent", text),
			selectedText: (text: string) => theme.fg("accent", text),
			description: (text: string) => theme.fg("muted", text),
			scrollInfo: (text: string) => theme.fg("dim", text),
			noMatch: (text: string) => theme.fg("warning", text),
		};
		const editor = new Editor(tui, { borderColor: (text) => theme.fg("accent", text), selectList: selectTheme });
		const setInputMode = (active: boolean) => {
			inputMode = active;
			editor.focused = focused && active;
			inputError = "";
		};
		const finish = (cancel: boolean) => {
			if (closed) return;
			closed = true;
			signal?.removeEventListener("abort", onAbort);
			done(cancel ? cancelled() : { questions, answers: questions.map((question) => answers.get(question.id)!), cancelled: false });
		};
		const onAbort = () => finish(true);
		const advance = () => {
			if (questions.length === 1) finish(false);
			else currentTab = Math.min(currentTab + 1, questions.length);
			refresh();
		};
		const lists = questions.map((question) => {
			// Internal numeric keys avoid reserving a possible user-provided option value for Other.
			const items = question.options.map((option, index) => ({
				value: String(index),
				label: `${index + 1}. ${option.label}${option.value === question.recommendation?.value ? " [recommended]" : ""}`,
				description: option.description,
			}));
			if (question.allowOther) items.push({ value: String(items.length), label: `${items.length + 1}. Other — type your answer`, description: undefined });
			const list = new SelectList(items, 7, selectTheme, { minPrimaryColumnWidth: 20, maxPrimaryColumnWidth: 50 });
			list.setSelectedIndex(Math.max(0, question.options.findIndex((option) => option.value === question.recommendation?.value)));
			list.onSelectionChange = refresh;
			list.onCancel = () => finish(true);
			list.onSelect = (item) => {
				const index = Number(item.value);
				if (index === question.options.length) {
					editor.setText(drafts.get(question.id) ?? "");
					setInputMode(true);
					refresh();
				} else {
					answers.set(question.id, choiceAnswer(question, index));
					advance();
				}
			};
			return list;
		});
		editor.onSubmit = (text) => {
			const question = questions[currentTab];
			if (!text.trim()) {
				inputError = "Please enter a non-empty answer.";
				refresh();
				return;
			}
			drafts.set(question.id, text.trim());
			answers.set(question.id, customAnswer(question, text.trim()));
			setInputMode(false);
			advance();
		};
		const keyLabel = (action: Parameters<typeof keybindings.getKeys>[0]) => keybindings.getKeys(action).join("/") || "(unbound)";

		signal?.addEventListener("abort", onAbort, { once: true });
		if (signal?.aborted) queueMicrotask(onAbort);

		return {
			get focused() { return focused; },
			set focused(value: boolean) { focused = value; editor.focused = value && inputMode; },
			handleInput(data: string) {
				if (closed) return;
				if (inputMode) {
					if (keybindings.matches(data, "tui.select.cancel")) {
						drafts.set(questions[currentTab].id, editor.getExpandedText());
						setInputMode(false);
					} else editor.handleInput(data);
					refresh();
					return;
				}
				if (keybindings.matches(data, "tui.select.cancel")) {
					finish(true);
					return;
				}
				if (questions.length > 1) {
					let direction = 0;
					if (matchesKey(data, Key.tab) || matchesKey(data, Key.right)) direction = 1;
					if (matchesKey(data, Key.shift("tab")) || matchesKey(data, Key.left)) direction = -1;
					if (direction) {
						currentTab = (currentTab + direction + questions.length + 1) % (questions.length + 1);
						refresh();
						return;
					}
				}
				if (currentTab === questions.length) {
					if (keybindings.matches(data, "tui.select.confirm")) {
						const missing = questions.findIndex((question) => !answers.has(question.id));
						if (missing < 0) finish(false);
						else { currentTab = missing; refresh(); }
					}
					return;
				}
				const list = lists[currentTab];
				if (/^[1-9]$/.test(data)) {
					const index = Number(data) - 1;
					const question = questions[currentTab];
					if (index < question.options.length + Number(question.allowOther)) {
						list.setSelectedIndex(index);
						list.onSelect?.(list.getSelectedItem()!);
					}
				} else list.handleInput(data);
				refresh();
			},
			render(width: number): string[] {
				const renderWidth = Math.max(1, width);
				const lines: string[] = [];
				const add = (text: string) => lines.push(...wrapTextWithAnsi(text, renderWidth));
				lines.push(theme.fg("accent", "─".repeat(renderWidth)));
				add(theme.fg("accent", theme.bold("Questionnaire")));
				if (questions.length > 1) {
					const tabs = [...questions.map((question) => `${answers.has(question.id) ? "✓" : "○"} ${question.label}`), "Review & submit"];
					add(tabs.map((label, i) => i === currentTab
						? theme.bg("selectedBg", theme.fg("text", ` ${label} `))
						: theme.fg("muted", ` ${label} `)).join(" "));
				}
				lines.push("");
				const question = questions[currentTab];
				if (!question) {
					add(theme.fg("accent", theme.bold("Review your answers")));
					for (const item of questions) {
						const answer = answers.get(item.id);
						add(theme.fg("muted", `${item.label}: `) + (answer
							? theme.fg("text", `${answer.label}${answer.wasCustom ? " (other)" : answer.wasRecommended ? " [recommended]" : ""}`)
							: theme.fg("warning", "(unanswered)")));
					}
					lines.push("");
					add(theme.fg("muted", `${keyLabel("tui.select.confirm")}: ${answers.size === questions.length ? "submit answers" : "go to first unanswered question"}`));
				} else {
					add(theme.fg("text", theme.bold(question.prompt)));
					if (question.recommendation) {
						const option = question.options.find((item) => item.value === question.recommendation!.value)!;
						add(theme.fg("success", `Recommended: ${option.label}`));
						add(theme.fg("muted", `Why: ${question.recommendation.reason}`));
					}
					lines.push("");
					lines.push(...lists[currentTab].render(renderWidth));
					const selected = lists[currentTab].getSelectedItem();
					const option = selected && question.options[Number(selected.value)];
					if (option) {
						lines.push("");
						add(theme.fg("text", option.label));
						if (option.description) add(theme.fg("muted", option.description));
					}
					if (inputMode) {
						lines.push("");
						add(theme.fg("muted", "Your answer:"));
						// Reserve enough layout space for a wide grapheme plus the editor's cursor column.
						lines.push(...editor.render(Math.max(4, renderWidth)));
						if (inputError) add(theme.fg("warning", inputError));
					} else if (answers.has(question.id)) {
						add(theme.fg("success", `Saved: ${answers.get(question.id)!.label}`));
					}
				}
				lines.push("");
				add(theme.fg("dim", inputMode
					? `${keyLabel("tui.input.submit")} submit • ${keyLabel("tui.input.newLine")} newline • ${keyLabel("tui.select.cancel")} back`
					: `${keyLabel("tui.select.up")}/${keyLabel("tui.select.down")} choose • ${keyLabel("tui.select.confirm")} select • 1–9 quick select • ${keyLabel("tui.select.cancel")} cancel`));
				if (!inputMode && questions.length > 1) add(theme.fg("dim", "Tab/←→ switch questions • Shift+Tab previous • Review before submitting"));
				lines.push(theme.fg("accent", "─".repeat(renderWidth)));
				// Clipping also handles terminals too narrow to fit a wide Unicode grapheme or list prefix.
				return lines.map((line) => truncateToWidth(line, renderWidth, ""));
			},
			invalidate() { editor.invalidate(); for (const list of lists) list.invalidate(); },
			dispose() { closed = true; editor.focused = false; signal?.removeEventListener("abort", onAbort); },
		};
	});
}

export default function questionnaire(pi: ExtensionAPI) {
	pi.registerTool<typeof QuestionnaireParams, Result>({
		name: "questionnaire",
		label: "Questionnaire",
		description: "Ask the user one or more single-choice questions, with option descriptions and an optional recommended option plus rationale. Supports custom Other answers and review before submitting multiple answers. Recommendations are suggestions, never automatic answers.",
		promptSnippet: "Ask questions with selectable choices and a recommendation",
		promptGuidelines: [
			"Use questionnaire when you need the user to choose between approaches, clarify requirements, or express preferences; keep the questions and choices concise.",
			"Include recommendation { value, reason } when one choice is preferable, explaining the relevant trade-off. Its value must match an option. Other answers are allowed by default.",
			"Only submitted questionnaire answers are user decisions. Cancellation, highlighted choices, and recommendations are not consent; do not repeatedly reopen a cancelled questionnaire.",
		],
		parameters: QuestionnaireParams,
		outputSchema: ResultSchema,
		exposure: "model-only",
		executionMode: "sequential",
		annotations: { readOnlyHint: true, destructiveHint: false, openWorldHint: false },
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const details = await askQuestions(params.questions, ctx, signal);
			return { content: [{ type: "text", text: resultText(details) }], details, structuredContent: details };
		},
		renderCall(args, theme) {
			const questions = Array.isArray(args.questions) ? args.questions : [];
			const labels = questions.map((question) => question?.label ?? question?.id).filter(Boolean).join(", ");
			return new Text(theme.fg("toolTitle", theme.bold("questionnaire "))
				+ theme.fg("muted", `${questions.length} question${questions.length === 1 ? "" : "s"}${labels ? ` (${labels})` : ""}`), 0, 0);
		},
		renderResult(result, { isPartial, expanded }, theme) {
			if (isPartial) return new Text(theme.fg("muted", "Waiting for answers…"), 0, 0);
			const details = result.details;
			if (!details) return new Text(result.content.filter((item) => item.type === "text").map((item) => item.text).join("\n"), 0, 0);
			if (details.cancelled) return new Text(theme.fg("warning", "Cancelled — no answers submitted"), 0, 0);
			return new Text(details.answers.map((answer) => {
				const question = details.questions.find((item) => item.id === answer.id);
				const badge = answer.wasCustom ? " (other)" : answer.wasRecommended ? " [recommended]" : "";
				const line = theme.fg("success", "✓ ") + theme.fg("accent", `${question?.label ?? answer.id}: `) + answer.label + theme.fg("muted", badge);
				return expanded && question ? `${theme.fg("muted", question.prompt)}\n${line}` : line;
			}).join("\n"), 0, 0);
		},
	});

}
