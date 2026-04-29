/**
 * Rounded editor box
 *
 * Renders the prompt input as a full rounded card/box instead of the default
 * top-and-bottom-only borders.
 *
 * Border colors:
 *   - Normal mode → accent = iris  (#c4a7e7 in rosepine)
 *   - Bash mode   → bashMode = gold (#f6c177 in rosepine)
 *
 * Padding strategy
 * ─────────────────
 * paddingX stays at 1 (the default) so pi's global content layout (tool
 * blocks, messages, etc.) is unaffected.
 *
 * To get one extra character of visual padding *inside* the box we call
 * super.render(width - 4) — four fewer columns than the terminal width:
 *
 *   2 columns  →  left │ + one explicit space
 *   2 columns  →  one explicit space + right │
 *
 * The editor fills each content line to (width - 4), so wrapping:
 *   │  <content padded to width-4>  │   = width total
 *
 * The top/bottom borders are regenerated at (width - 2) so the corners
 * always span the full box width regardless of the content render width.
 *
 * Autocomplete fix
 * ─────────────────
 * Editor.render() appends autocomplete items *after* the bottom border line,
 * not between the two borders.  We scan backwards to find the real bottom
 * border, skip it in its original position, and emit it as ╰╯ at the very
 * end so the dropdown stays inside the box.
 */

import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@mariozechner/pi-coding-agent";
import type { EditorTheme, TUI } from "@mariozechner/pi-tui";
import { visibleWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		class RoundedBoxEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				// paddingX: 1 (default) — keeps tool-block / message layout unchanged.
				super(tui, theme, keybindings, { paddingX: 1 });
			}

			render(width: number): string[] {
				// Content area: 2 cols for │ borders + 1 explicit space on each side = 4.
				const contentRenderWidth = width - 4;
				// Border area: 2 cols for ╭╮ / ╰╯ corners only.
				const borderInner = width - 2;

				if (contentRenderWidth <= 0) return super.render(width);

				const lines = super.render(contentRenderWidth);
				if (lines.length === 0) return lines;

				const isBash = this.getText().startsWith("!");
				const b = isBash
					? (s: string) => ctx.ui.theme.fg("bashMode", s)
					: (s: string) => ctx.ui.theme.fg("accent", s);

				// Strip ANSI escape codes to inspect raw characters.
				const stripAnsi = (s: string) => s.replace(/\x1b\[[0-9;]*[a-zA-Z]/g, "");

				// Border lines always start with ─ after stripping ANSI.
				// Content / autocomplete lines always start with a space (paddingX = 1),
				// so this reliably identifies only the editor's own border lines.
				const isBorderLine = (line: string) => {
					const raw = stripAnsi(line);
					return raw.length > 0 && raw[0] === "─";
				};

				// Scan backwards past any autocomplete items to find the real bottom border.
				let bottomIdx = lines.length - 1;
				while (bottomIdx > 0 && !isBorderLine(lines[bottomIdx]!)) {
					bottomIdx--;
				}

				const result: string[] = [];

				// Top edge — always regenerated at full border width.
				result.push(b("╭") + b("─".repeat(borderInner)) + b("╮"));

				for (let i = 1; i < lines.length; i++) {
					// Skip lines[0] (original top border, already replaced above).
					// Skip the original bottom border; we emit it freshly at the end.
					if (i === bottomIdx) continue;

					const line = lines[i]!;

					// The editor pads every content/autocomplete line to contentRenderWidth,
					// so no extra fill is needed — just the explicit spaces and │ borders.
					const lw = visibleWidth(line);
					const fill = lw < contentRenderWidth ? " ".repeat(contentRenderWidth - lw) : "";
					result.push(b("│") + " " + line + fill + " " + b("│"));
				}

				// Bottom edge — always regenerated at full border width, placed last so
				// autocomplete items (if any) are enclosed inside the rounded box.
				result.push(b("╰") + b("─".repeat(borderInner)) + b("╯"));

				return result;
			}
		}

		ctx.ui.setEditorComponent(
			(tui, theme, keybindings) => new RoundedBoxEditor(tui, theme, keybindings),
		);
	});
}
