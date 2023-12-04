module main

import iui as ui
import net.html
import gx

// PLACEHOLDER
struct EmptyElement {
	HElement
mut:
	inner_text string
}

fn (mut el EmptyElement) draw(ctx &ui.GraphicsContext) {
	el.HElement.draw(ctx)
}

// PLACEHOLDER
struct TextElement {
	HElement
mut:
	inner_text string
}

fn (mut el TextElement) draw(ctx &ui.GraphicsContext) {
	el.debug_draw(el, ctx)
	// println('TEXT DRAW ${el.tag.name} ${el.kids.len} ${ft(el.inner_text)}')

	if el.inner_text.len > 0 {
		tw := ctx.text_width(el.inner_text)
		el.width = tw
		if tw > 0 {
			el.height = ctx.gg.text_height(el.inner_text)
		}
	}

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.draw_text(el.x, el.y, el.inner_text, 0)
	}

	el.HElement.draw(ctx)
}

// PLACEHOLDER
struct DivElement {
	HElement
mut:
	inner_text string
}

fn (mut el DivElement) draw(ctx &ui.GraphicsContext) {
	// println('TEXT DRAW ${el.tag.name} ${el.kids.len} ${ft(el.inner_text)}')
	el.debug_draw(el, ctx)

	if el.inner_text.len > 0 {
		tw := ctx.text_width(el.inner_text)
		el.width = tw
		if tw > 0 {
			el.height = ctx.gg.text_height(el.inner_text)
		}
	}

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.draw_text(el.x, el.y, el.inner_text, 0)
	}

	el.HElement.draw(ctx)

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
	el.HElement.draw(ctx)
}

// PLACEHOLDER
struct BodyElement {
	HElement
mut:
	inner_text string
}

fn (mut el BodyElement) draw(ctx &ui.GraphicsContext) {
	el.debug_draw(el, ctx)

	el.HElement.draw(ctx)
}

// PLACEHOLDER
struct MetaElement {
	HElement
mut:
	inner_text string
}

fn (mut el MetaElement) draw(ctx &ui.GraphicsContext) {
	el.HElement.draw(ctx)
}

// PLACEHOLDER
struct StyleElement {
	HElement
mut:
	inner_text string
}

fn (mut el StyleElement) draw(ctx &ui.GraphicsContext) {
	el.HElement.draw(ctx)
}

// PLACEHOLDER
struct InputElement {
	HElement
mut:
	inner_text string
}

fn (mut el InputElement) draw(ctx &ui.GraphicsContext) {
	if 'size' in el.tag.attributes {
		mins := ctx.text_width('a') * el.tag.attributes['size'].int()
		if el.width < mins {
			el.width = mins
			el.height = ctx.line_height
		}
	}

	ctx.gg.draw_rect_empty(el.x, el.y, el.width, el.height, gx.green)

	el.HElement.draw(ctx)
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
		el.width = el.img.width
		el.height = el.img.height

		el.add_child(el.img)
	}

	el.width = el.img.width
	el.height = el.img.height

	// el.img.draw_with_offset(ctx, el.x, el.y)
	for mut kid in el.children {
		// if mut kid is ui.Image {
		kid.draw_with_offset(ctx, el.x, el.y)
		//}
	}

	ctx.gg.draw_rect_empty(el.x, el.y, el.width, el.height, gx.red)

	el.HElement.draw(ctx)
}
