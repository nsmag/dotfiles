import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { getEventListeners } from "node:events";
import { existsSync, readFileSync, realpathSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";

// Resolve the installed host instead of installing duplicate Pi dependencies.
const packageDir = process.env.PI_PACKAGE_DIR ?? (() => {
	const cli = realpathSync(execFileSync("which", ["pi"], { encoding: "utf8" }).trim());
	for (const directory of createRequire(cli).resolve.paths("@earendil-works/pi-coding-agent") ?? []) {
		const manifest = join(directory, "@earendil-works/pi-coding-agent/package.json");
		if (existsSync(manifest) && JSON.parse(readFileSync(manifest, "utf8")).name === "@earendil-works/pi-coding-agent") return dirname(realpathSync(manifest));
	}
	throw new Error("Cannot locate Pi's package directory. Set PI_PACKAGE_DIR to its installed package directory.");
})();
const require = createRequire(join(packageDir, "package.json"));
const { loadExtensions, discoverAndLoadExtensions } = await import(pathToFileURL(join(packageDir, "dist/core/extensions/loader.js")));
const { Check } = await import(pathToFileURL(require.resolve("typebox/value")));
const { CURSOR_MARKER, getKeybindings, setKeybindings, KeybindingsManager, TUI_KEYBINDINGS, visibleWidth } = await import(pathToFileURL(require.resolve("@earendil-works/pi-tui")));
const extensionPath = fileURLToPath(new URL("./index.ts", import.meta.url));
const loaded = await loadExtensions([extensionPath], process.cwd());
assert.deepEqual(loaded.errors, []);
const extension = loaded.extensions[0];
const tool = extension.tools.get("questionnaire").definition;

const first = {
	id: "first", label: "First", prompt: "Which approach?",
	options: [
		{ value: "a", label: "First choice", description: "One trade-off." },
		{ value: "b", label: "Second choice", description: "Another trade-off." },
	],
	recommendation: { value: "b", reason: "It fits the current requirements." },
};
const second = { ...first, id: "second", label: "Second", prompt: "Which test strategy?" };
const args = (...questions) => ({ questions });
const plain = (lines) => lines.join("\n").replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");

async function simulateTui(parameters, interact, signal, beforeFactory) {
	const context = {
		mode: "tui", hasUI: true,
		ui: {
			async custom(factory) {
				let finished = false;
				let color = 36;
				let resolve;
				const completion = new Promise((done) => { resolve = done; });
				const tui = { terminal: { rows: 40, columns: 80 }, requestRender() {} };
				const theme = {
					fg: (_token, text) => `\x1b[${color}m${text}\x1b[39m`,
					bg: (_token, text) => `\x1b[44m${text}\x1b[49m`,
					bold: (text) => `\x1b[1m${text}\x1b[22m`,
				};
				beforeFactory?.();
				const component = await factory(tui, theme, getKeybindings(), (result) => {
					assert.equal(finished, false, "completion must be idempotent");
					finished = true;
					resolve(result);
				});
				component.focused = true;
				try {
					await interact(component, { get finished() { return finished; }, changeTheme() { color = 32; } });
					assert.equal(finished, true, "test must submit or cancel the questionnaire");
					return await completion;
				} finally { component.dispose?.(); }
			},
		},
	};
	const result = await tool.execute("test", parameters, signal, undefined, context);
	assert.equal(Check(tool.outputSchema, result.structuredContent), true);
	assert.deepEqual(result.details, result.structuredContent);
	return result.details;
}

async function simulateRpc(parameters, ui, signal) {
	const result = await tool.execute("test", parameters, signal, undefined, { mode: "rpc", hasUI: true, ui });
	assert.equal(Check(tool.outputSchema, result.structuredContent), true);
	return result.details;
}

test("registers a sequential, model-only tool without slash commands", async () => {
	assert.equal(tool.executionMode, "sequential");
	assert.equal(tool.exposure, "model-only");
	assert.equal(extension.commands.size, 0);
	assert.equal(Check(tool.parameters, args(first)), true);
	assert.equal(Check(tool.parameters, args()), false);
	assert.equal(Check(tool.parameters, args({ ...first, options: [] })), false);
	const discovered = await discoverAndLoadExtensions([], process.cwd(), dirname(dirname(dirname(extensionPath))));
	assert.deepEqual(discovered.errors.filter((error) => error.path.startsWith(dirname(extensionPath))), []);
	assert.equal(discovered.extensions.filter((item) => item.path.startsWith(dirname(extensionPath))).length, 1, "tests must not be discovered as extensions");
});

test("single question highlights its recommendation but requires a selection", async () => {
	const result = await simulateTui(args(first), (component, state) => {
		assert.match(plain(component.render(80)), /Recommended: Second choice/);
		assert.match(plain(component.render(80)), /Why: It fits the current requirements/);
		assert.equal(state.finished, false);
		component.handleInput("\r");
	});
	assert.deepEqual(result.answers, [{ id: "first", value: "b", label: "Second choice", wasCustom: false, wasRecommended: true }]);
	assert.equal(result.cancelled, false);
});

test("arrow navigation can select a non-recommended choice", async () => {
	const result = await simulateTui(args(first), (component) => {
		component.handleInput("\x1b[A");
		component.handleInput("\r");
	});
	assert.equal(result.answers[0].value, "a");
	assert.equal(result.answers[0].wasRecommended, false);
});

test("multi-question review requires every answer and preserves edits in question order", async () => {
	const result = await simulateTui(args(first, second), (component, state) => {
		component.handleInput("\t"); // Skip Q1.
		component.handleInput("2"); // Answer Q2, then review.
		assert.match(plain(component.render(80)), /First: .*unanswered/);
		assert.equal(state.finished, false);
		component.handleInput("\r"); // Return to missing Q1, not submit.
		assert.match(plain(component.render(80)), /Which approach/);
		component.handleInput("1"); // Answer Q1, advance to Q2.
		assert.match(plain(component.render(80)), /Saved: Second choice/);
		component.handleInput("\t"); // Review.
		component.handleInput("\x1b[Z"); // Back to Q2.
		component.handleInput("1"); // Revise Q2, then review.
		assert.equal(state.finished, false);
		component.handleInput("\r");
	});
	assert.deepEqual(result.answers.map(({ id, value }) => ({ id, value })), [{ id: "first", value: "a" }, { id: "second", value: "a" }]);
});

test("Other supports focus, blank-answer validation, multiline text, and preserved drafts", async () => {
	const result = await simulateTui(args(first), (component, state) => {
		component.handleInput("3");
		assert.equal(component.render(80).some((line) => line.includes(CURSOR_MARKER)), true);
		component.focused = false;
		assert.equal(component.render(80).some((line) => line.includes(CURSOR_MARKER)), false);
		component.focused = true;
		component.handleInput("\r");
		assert.equal(state.finished, false);
		assert.match(plain(component.render(80)), /non-empty answer/);
		component.handleInput("draft");
		component.handleInput("\x1b");
		assert.equal(state.finished, false);
		component.handleInput("3");
		assert.match(plain(component.render(80)), /draft/);
		component.handleInput("\n"); // Ctrl+J, a newline.
		component.handleInput("\x1b[200~custom 🌲 answer\x1b[201~");
		component.handleInput("\r");
	});
	assert.equal(result.answers[0].value, "draft\ncustom 🌲 answer");
	assert.equal(result.answers[0].wasCustom, true);
	assert.equal(result.answers[0].wasRecommended, false);
});

test("cancellation discards drafts and previously answered questions", async () => {
	const result = await simulateTui(args(first, second), (component) => {
		component.handleInput("1");
		component.handleInput("\x1b");
	});
	assert.equal(result.cancelled, true);
	assert.deepEqual(result.answers, []);
});

test("allowOther false restricts choices and option values do not collide with Other", async () => {
	const result = await simulateTui(args({ ...first, allowOther: false, options: [{ value: "__other__", label: "A real option" }], recommendation: undefined }), (component, state) => {
		assert.doesNotMatch(plain(component.render(80)), /Other —/);
		component.handleInput("2");
		assert.equal(state.finished, false);
		component.handleInput("1");
	});
	assert.equal(result.answers[0].value, "__other__");
	assert.equal(result.answers[0].wasCustom, false);
});

test("scrolling, Unicode, ANSI colors, resizing, and editor lines stay within terminal width", async () => {
	const options = Array.from({ length: 12 }, (_, i) => ({ value: String(i), label: `选择 🌲 ${i} ${"long label ".repeat(5)}`, description: "界面描述 ".repeat(20) }));
	await simulateTui(args({ ...first, prompt: "选择 🌲 a strategy", options, recommendation: { value: "11", reason: "推荐原因 ".repeat(20) } }, second), (component, state) => {
		const checkWidths = () => {
			for (const width of [1, 2, 3, 4, 10, 20, 40, 80, 120, 20]) {
				for (const line of component.render(width)) assert.ok(visibleWidth(line) <= width, `line exceeds ${width} columns: ${JSON.stringify(line)}`);
			}
		};
		checkWidths();
		assert.match(component.render(80).join("\n"), /\x1b\[36m/);
		state.changeTheme();
		component.invalidate();
		assert.doesNotMatch(component.render(80).join("\n"), /\x1b\[36m/);
		component.handleInput("\x1b[B"); // Other follows the recommended last choice.
		component.handleInput("\r");
		component.handleInput("\x1b[200~中文🌲 a custom answer\x1b[201~");
		checkWidths();
		component.handleInput("\r"); // Q2.
		checkWidths();
		component.handleInput("1"); // Review.
		checkWidths();
		component.handleInput("\r");
	});
});

test("selection respects configured keybindings", async () => {
	const original = getKeybindings();
	setKeybindings(new KeybindingsManager(TUI_KEYBINDINGS, { "tui.select.up": "k", "tui.select.confirm": "y", "tui.select.cancel": "q" }));
	try {
		const result = await simulateTui(args(first), (component) => {
			component.handleInput("k");
			component.handleInput("y");
		});
		assert.equal(result.answers[0].value, "a");
	} finally { setKeybindings(original); }
});

test("aborting closes the terminal questionnaire and removes listeners", async () => {
	const controller = new AbortController();
	const result = await simulateTui(args(first), (component) => {
		assert.equal(getEventListeners(controller.signal, "abort").length, 1);
		controller.abort();
		component.handleInput("\r");
	}, controller.signal);
	assert.equal(result.cancelled, true);
	assert.equal(getEventListeners(controller.signal, "abort").length, 0);
	const completedController = new AbortController();
	await simulateTui(args(first), (component) => component.handleInput("1"), completedController.signal);
	assert.equal(getEventListeners(completedController.signal, "abort").length, 0);
});

test("an abort immediately before component creation does not leave a dialog open", async () => {
	const controller = new AbortController();
	const result = await simulateTui(args(first), () => {}, controller.signal, () => controller.abort());
	assert.equal(result.cancelled, true);
	assert.equal(getEventListeners(controller.signal, "abort").length, 0);
});

test("RPC includes recommendations, handles custom answers, and confirms multiple answers", async () => {
	const controller = new AbortController();
	let selects = 0;
	let inputs = 0;
	let warnings = 0;
	let confirmed = false;
	const result = await simulateRpc(args(first, second), {
		async select(title, choices, options) {
			assert.equal(options.signal, controller.signal);
			assert.match(title, /Recommended: Second choice\nWhy:/);
			assert.match(choices[1], /\[recommended\]/);
			return choices[selects++ === 0 ? 1 : 2];
		},
		async input() { return inputs++ === 0 ? "   " : "  A custom answer  "; },
		notify() { warnings++; },
		async confirm(title, summary, options) {
			assert.equal(options.signal, controller.signal);
			assert.match(summary, /First: Second choice\nSecond: A custom answer/);
			confirmed = true;
			return true;
		},
	}, controller.signal);
	assert.equal(confirmed, true);
	assert.equal(warnings, 1);
	assert.equal(result.answers[0].wasRecommended, true);
	assert.equal(result.answers[1].wasCustom, true);
});

test("RPC cancellation never submits partial answers", async () => {
	for (const cancelAt of ["select", "input", "confirm"]) {
		let count = 0;
		const result = await simulateRpc(args(first, second), {
			async select(_title, choices) {
				if (count++ === 0) return choices[0];
				return cancelAt === "select" ? undefined : choices[2];
			},
			async input() { return cancelAt === "input" ? undefined : "custom"; },
			async confirm() { return false; },
		});
		assert.equal(result.cancelled, true);
		assert.deepEqual(result.answers, []);
	}
});

test("invalid questionnaire semantics fail before opening a UI", async () => {
	const cases = [args(), args(first, first), args({ ...first, id: " " }), args({ ...first, prompt: " " }), args({ ...first, label: " " }), args({ ...first, options: [] }), args({ ...first, options: [first.options[0], first.options[0]] }), args({ ...first, options: [{ value: " ", label: "Valid" }] }), args({ ...first, options: [{ value: "a", label: " " }] }), args({ ...first, recommendation: { value: "missing", reason: "why" } }), args({ ...first, recommendation: { value: "a", reason: " " } })];
	for (const parameters of cases) {
		await assert.rejects(tool.execute("test", parameters, undefined, undefined, { mode: "tui", hasUI: true, ui: { custom() { assert.fail("must not open UI"); } } }));
	}
});

test("non-interactive modes fail explicitly and pre-aborted calls do not open dialogs", async () => {
	for (const mode of ["print", "json"]) await assert.rejects(tool.execute("test", args(first), undefined, undefined, { mode, hasUI: false }), /interactive or RPC UI/);
	const result = await tool.execute("test", args(first), AbortSignal.abort(), undefined, { mode: "tui", hasUI: true, ui: { custom() { assert.fail("must not open UI"); } } });
	assert.equal(result.details.cancelled, true);
	assert.match(result.content[0].text, /No answers were submitted/);
	assert.equal(Check(tool.outputSchema, result.structuredContent), true);
});

test("renderers tolerate partial calls, missing details, and cancelled results", () => {
	const theme = { fg: (_token, text) => text, bold: (text) => text };
	assert.ok(tool.renderCall({}, theme).render(20).length);
	assert.ok(tool.renderCall({ questions: [{}] }, theme).render(20).length);
	assert.match(plain(tool.renderResult({}, { isPartial: true }, theme).render(80)), /Waiting/);
	assert.match(plain(tool.renderResult({ content: [{ type: "text", text: "UI unavailable" }] }, {}, theme).render(80)), /UI unavailable/);
	assert.match(plain(tool.renderResult({ details: { cancelled: true } }, {}, theme).render(80)), /Cancelled/);
});
