/**
 * Rounded editor box with pane-focus awareness
 *
 * Renders the prompt input as a full rounded card/box instead of the default
 * top-and-bottom-only borders.
 *
 * Border colors:
 *   - Active pane, normal mode → accent = iris  (#c4a7e7 in rosepine)
 *   - Active pane, bash mode   → bashMode = gold (#f6c177 in rosepine)
 *   - Inactive pane            → dim (grayed out, hardware cursor hidden)
 *
 * Pane focus detection
 * ─────────────────────
 * Terminals report focus via ANSI sequences when `\x1b[?1004h` is sent:
 *   \x1b[I  →  pane gained focus
 *   \x1b[O  →  pane lost focus
 *
 * In tmux you must also add to ~/.tmux.conf:
 *   set -g focus-events on
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
import { CURSOR_MARKER, visibleWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		// Request terminal focus-event reporting for this session.
		process.stdout.write("\x1b[?1004h");

		class RoundedBoxEditor extends CustomEditor {
			/** True while this terminal pane has OS-level focus. */
			private paneFocused = true;
			private _tui: TUI;

			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				// paddingX: 1 (default) — keeps tool-block / message layout unchanged.
				super(tui, theme, keybindings, { paddingX: 1 });
				this._tui = tui;
			}

			override handleInput(data: string): void {
				if (data === "\x1b[I") {
					// Terminal pane gained focus.
					if (!this.paneFocused) {
						this.paneFocused = true;
						this.invalidate();
						this._tui.requestRender();
					}
					return;
				}
				if (data === "\x1b[O") {
					// Terminal pane lost focus.
					if (this.paneFocused) {
						this.paneFocused = false;
						this.invalidate();
						this._tui.requestRender();
					}
					return;
				}
				super.handleInput(data);
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
				// Dim the border when the pane is not focused so it's easy to
				// spot the active pi instance in a tmux multi-pane layout.
				const b = !this.paneFocused
					? (s: string) => ctx.ui.theme.fg("dim", s)
					: isBash
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

				// When the pane is not focused:
				//  1. Strip CURSOR_MARKER so the TUI does not show the hardware cursor.
				//  2. Dim the block-style fake cursor (\x1b[7m…\x1b[27m reverse-video)
				//     by prepending \x1b[2m (dim on) and appending \x1b[22m (dim off).
				if (!this.paneFocused) {
					return result.map((l) =>
						l
							.split(CURSOR_MARKER).join("")
							.replace(/\x1b\[7m/g, "\x1b[2m")
							.replace(/\x1b\[27m/g, "\x1b[22m")
					);
				}

				return result;
			}
		}

		ctx.ui.setEditorComponent(
			(tui, theme, keybindings) => new RoundedBoxEditor(tui, theme, keybindings),
		);
	});

	pi.on("session_shutdown", () => {
		// Disable terminal focus-event reporting so the sequences don't
		// leak into other programs that run in this terminal after pi exits.
		process.stdout.write("\x1b[?1004l");
	});
}
