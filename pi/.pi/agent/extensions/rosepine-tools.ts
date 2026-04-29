/**
 * Rose Pine tool renderer — strips the default colored background from all built-in
 * tool blocks and replaces it with a single left-edge stripe whose color reflects the
 * tool's state:
 *
 *   dim  ▎  (pending / running)
 *   pine ▎  (success)          — #31748f, full-saturation, no dimming needed
 *   love ▎  (error)            — #eb6f92, full-saturation, no dimming needed
 *
 * Works by overriding every built-in tool with renderShell:"self" and wrapping
 * the original call/result components inside StripeWrapper, which prefixes every
 * rendered line with the coloured stripe character.
 */

import type {
  ExtensionAPI,
  ToolDefinition,
  ToolRenderResultOptions,
  Theme,
} from "@mariozechner/pi-coding-agent";
import {
  createBashToolDefinition,
  createEditToolDefinition,
  createFindToolDefinition,
  createGrepToolDefinition,
  createLsToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
} from "@mariozechner/pi-coding-agent";
import type { Component } from "@mariozechner/pi-tui";

// ToolRenderContext is an internal type not exported from the public API.
// Derive it structurally so the LSP is happy without depending on internals.
type ToolRenderContext = Parameters<NonNullable<ToolDefinition<any, any>["renderCall"]>>[2];

// ---------------------------------------------------------------------------
// StripeWrapper
// ---------------------------------------------------------------------------

/**
 * Wraps any Component and prepends a coloured stripe character to every line.
 * The inner component is stored so the caller can swap it cheaply on re-renders
 * while preserving the wrapper instance (needed for lastComponent reuse).
 */
class StripeWrapper implements Component {
  innerComponent: Component;
  private prefix: string;

  constructor(inner: Component, prefix: string) {
    this.innerComponent = inner;
    this.prefix = prefix;
  }

  setPrefix(prefix: string): void {
    this.prefix = prefix;
  }

  render(width: number): string[] {
    // "▎ " occupies 2 display cells (the block character + one space)
    const inner = this.innerComponent.render(Math.max(1, width - 2));
    return inner.map((line) => this.prefix + line);
  }

  invalidate(): void {
    this.innerComponent.invalidate?.();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Compute the coloured stripe prefix for the current render state. */
function stripePrefix(context: ToolRenderContext, theme: Theme): string {
  if (context.isPartial) return theme.fg("dim", "▎") + " ";
  if (context.isError) return theme.fg("error", "▎") + " ";
  // success — use pine via the thinkingLow token (= pine in rosepine theme)
  return theme.fg("thinkingLow", "▎") + " ";
}

/**
 * Wrap a renderCall invocation in a StripeWrapper.
 * Forwards the inner component as lastComponent so built-in renderers can
 * reuse their internal components across re-renders (important for the write
 * tool's incremental syntax-highlight cache and the bash timing state).
 */
function wrapCall(
  origFn: (args: any, theme: Theme, ctx: ToolRenderContext) => Component,
  args: any,
  theme: Theme,
  context: ToolRenderContext,
): Component {
  const prefix = stripePrefix(context, theme);
  const prev = context.lastComponent instanceof StripeWrapper ? context.lastComponent : undefined;
  const inner = origFn(args, theme, { ...context, lastComponent: prev?.innerComponent });
  if (prev) {
    prev.innerComponent = inner;
    prev.setPrefix(prefix);
    return prev;
  }
  return new StripeWrapper(inner, prefix);
}

/**
 * Wrap a renderResult invocation in a StripeWrapper.
 * Same lastComponent forwarding approach as wrapCall.
 */
function wrapResult(
  origFn: (
    result: any,
    options: ToolRenderResultOptions,
    theme: Theme,
    ctx: ToolRenderContext,
  ) => Component,
  result: any,
  options: ToolRenderResultOptions,
  theme: Theme,
  context: ToolRenderContext,
): Component {
  const prefix = stripePrefix(context, theme);
  const prev = context.lastComponent instanceof StripeWrapper ? context.lastComponent : undefined;
  const inner = origFn(result, options, theme, { ...context, lastComponent: prev?.innerComponent });
  if (prev) {
    prev.innerComponent = inner;
    prev.setPrefix(prefix);
    return prev;
  }
  return new StripeWrapper(inner, prefix);
}

/**
 * Take an existing built-in ToolDefinition and return a new one that:
 *  - uses renderShell:"self" (no background Box from ToolExecutionComponent)
 *  - wraps renderCall / renderResult in StripeWrapper
 *  - delegates execute / prepareArguments / everything else unchanged
 */
function withStripe<TDetails>(
  def: ToolDefinition<any, TDetails>,
): ToolDefinition<any, TDetails> {
  const origRenderCall = def.renderCall;
  const origRenderResult = def.renderResult;

  return {
    ...def,
    renderShell: "self",

    renderCall: origRenderCall
      ? (args: any, theme: Theme, context: ToolRenderContext) =>
          wrapCall(origRenderCall, args, theme, context)
      : undefined,

    renderResult: origRenderResult
      ? (result: any, options: ToolRenderResultOptions, theme: Theme, context: ToolRenderContext) =>
          wrapResult(origRenderResult, result, options, theme, context)
      : undefined,
  };
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  const cwd = process.cwd();

  const builtinDefs: ToolDefinition<any, any>[] = [
    createBashToolDefinition(cwd),
    createReadToolDefinition(cwd),
    createWriteToolDefinition(cwd),
    createEditToolDefinition(cwd),
    createFindToolDefinition(cwd),
    createGrepToolDefinition(cwd),
    createLsToolDefinition(cwd),
  ];

  for (const def of builtinDefs) {
    pi.registerTool(withStripe(def));
  }
}
