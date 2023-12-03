module main

import iui as ui
import net.html

// PLACEHOLDER
struct EmptyElement {
	HElement
mut:
	inner_text string
}

fn (mut el EmptyElement) draw(ctx &ui.GraphicsContext) {
	el.draw_kids(ctx)
}

// PLACEHOLDER
struct TextElement {
	HElement
mut:
	inner_text string
}

fn (mut el TextElement) draw(ctx &ui.GraphicsContext) {
	// println('TEXT DRAW ${el.tag.name} ${el.kids.len} ${ft(el.inner_text)}')
	ctx.draw_text(el.x, el.y, el.inner_text, 0)

	el.draw_kids(ctx)

	// test
	// ctx.draw_text(el.x, el.y, el.inner_text, 0)
}

// PLACEHOLDER
struct HtmlElement {
	HElement
mut:
	inner_text string
}

fn (mut el HtmlElement) draw(ctx &ui.GraphicsContext) {
	el.draw_kids(ctx)
}

// PLACEHOLDER
struct MetaElement {
	HElement
mut:
	inner_text string
}

fn (mut el MetaElement) draw(ctx &ui.GraphicsContext) {
	el.draw_kids(ctx)
}

// PLACEHOLDER
struct StyleElement {
	HElement
mut:
	inner_text string
}

fn (mut el StyleElement) draw(ctx &ui.GraphicsContext) {
	el.draw_kids(ctx)
}
