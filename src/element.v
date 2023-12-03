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

	tw := ctx.text_width(el.inner_text)
	el.width = tw

	el.height = ctx.line_height

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.draw_text(el.x, el.y, el.inner_text, 0)
	}

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

// PLACEHOLDER
struct ImgElement {
	HElement
mut:
	inner_text string
	img        &ui.Image
}

fn (mut el ImgElement) draw(ctx &ui.GraphicsContext) {
	if isnil(el.img) {
		el.img = el.page.handle_image(el.tag)
		el.add_child(el.img)
	}

	// el.img.draw_with_offset(ctx, el.x, el.y)
	for mut kid in el.children {
		// if mut kid is ui.Image {
		kid.draw_with_offset(ctx, el.x, el.y)
		//}
	}

	el.draw_kids(ctx)
}
