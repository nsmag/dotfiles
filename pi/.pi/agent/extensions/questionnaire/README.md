# Questionnaire

Adds the model-callable `questionnaire` tool without adding slash commands.

- One or more single-choice questions with descriptions.
- A highlighted recommended choice and an explanation of why it fits.
- An **Other** option with a multiline editor, enabled by default.
- Navigation between questions and a review screen before submitting multiple answers.
- Structured answers, including whether each answer was custom or recommended.
- Standard selection/input dialogs for RPC clients. Print/JSON mode returns an explicit error rather than inventing an answer.

## Load and try it

This directory is auto-discovered through `~/.pi/agent/extensions`. Run `/reload` in an existing Pi session to load changes.

For a one-off load from the dotfiles root:

```sh
pi -e ./pi/.pi/agent/extensions/questionnaire/index.ts
```

Once loaded, ask Pi to present a questionnaire whenever it needs your input.

## Tool arguments

```json
{
  "questions": [
    {
      "id": "approach",
      "label": "Approach",
      "prompt": "How should we implement this change?",
      "options": [
        {
          "value": "minimal",
          "label": "Minimal change",
          "description": "Solve the immediate problem without unrelated refactoring."
        },
        {
          "value": "refactor",
          "label": "Broader refactor",
          "description": "Restructure the surrounding code too."
        }
      ],
      "recommendation": {
        "value": "minimal",
        "reason": "A smaller diff is easier to review and reduces regression risk."
      },
      "allowOther": true
    }
  ]
}
```

Question IDs must be unique. Each question needs at least one option, with unique option values. `label` defaults to `Q1`, `Q2`, etc. `recommendation` is optional; its value must match an option and its reason cannot be blank. Set `allowOther: false` to restrict answers to the supplied choices.

Answers contain `id`, `value`, `label`, `wasCustom`, and `wasRecommended`, in question order. Cancelling discards all draft answers and returns `cancelled: true` with an empty answer list. A recommendation is initially highlighted, but never submitted without an explicit selection.

## Keyboard controls

| Key (defaults) | Action |
| --- | --- |
| ↑ / ↓ | Highlight a choice |
| Enter | Answer the current question, or submit on the review screen |
| 1–9 | Select a numbered choice directly |
| Tab / → | Next question or review |
| Shift+Tab / ← | Previous question or review |
| Esc / Ctrl+C | Cancel; in the Other editor, return to choices and preserve the draft |
| Shift+Enter / Ctrl+J | Newline in the Other editor |

Selection and editor actions respect Pi's configured keybindings. Tab/arrow question navigation and numbered shortcuts are extension-specific. On the review screen, Enter jumps to the first unanswered question if any are missing.

## Tests

With Pi installed on `PATH`:

```sh
node --test pi/.pi/agent/extensions/questionnaire/test.mjs
```

Tests load the real TypeScript extension through Pi's loader and exercise terminal interaction, RPC dialogs, validation, cancellation, structured results, and narrow-width rendering. If Pi is not on `PATH`, set `PI_PACKAGE_DIR` to the installed `@earendil-works/pi-coding-agent` package directory.
