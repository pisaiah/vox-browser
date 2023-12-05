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
	cfg_def := gx.TextCfg{
		size: ctx.font_size
	}

	fsr := el.page.styles.get_rule(el.tag.name, 'font-size')

	mut fs := ctx.font_size
	if fsr != none {
		fss := fsr or { '' }

		if fss.contains('em') {
			fs = int(ctx.font_size * fss.f32())
		}

		if fss.contains('px') {
			fs = fss.int()
		}
	}

	cfg := gx.TextCfg{
		size: fs
	}

	ctx.gg.set_text_cfg(cfg)

	if el.inner_text.len > 0 {
		tw := ctx.text_width(el.inner_text)
		el.width = tw
		if tw > 0 {
			el.height = ctx.gg.text_height(el.inner_text)
		}
	}

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.draw_text(el.x, el.y, el.inner_text, 0, cfg)

		ctx.gg.set_text_cfg(cfg_def)
	}

	el.HElement.draw(ctx)
	el.debug_draw(el, ctx)
}

// PLACEHOLDER
struct DivElement {
	HElement
mut:
	inner_text string
}

fn (mut el DivElement) draw(ctx &ui.GraphicsContext) {
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
	el.debug_draw(el, ctx)

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

	el.width = el.page.width

	el.HElement.draw(ctx)
	el.debug_draw(el, ctx)
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
struct AElement {
	HElement
mut:
	inner_text string
}

fn (mut el AElement) draw(ctx &ui.GraphicsContext) {

	link_color := gx.rgb(0, 100, 200)

	cfg_def := gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	}

	fsr := el.page.styles.get_rule(el.tag.name, 'font-size')

	mut fs := ctx.font_size
	if fsr != none {
		fss := fsr or { '' }

		if fss.contains('em') {
			fs = ctx.font_size * fss.int()
		}

		if fss.contains('px') {
			fs = fss.int()
		}
	}

	cfg := gx.TextCfg{
		size: fs
		color: link_color
	}

	ctx.gg.set_text_cfg(cfg)

	if el.inner_text.len > 0 {
		tw := ctx.text_width(el.inner_text)
		el.width = tw
		if tw > 0 {
			el.height = ctx.gg.text_height(el.inner_text)
		}
	}

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.draw_text(el.x, el.y, el.inner_text, 0, cfg)
		ctx.gg.draw_line(el.x, el.y + el.height, el.x + el.width, el.y + el.height, link_color)

		ctx.gg.set_text_cfg(cfg_def)
	}
	
	if el.is_mouse_rele {
		dump('click')
		
		if 'href' !in el.tag.attributes {
			dump('no href')
		} else {
			mut href := el.tag.attributes['href']
			
			if !href.contains('http') {
				href = el.page.url + href
			}
			
			dump(href)
			el.page.load(href)
		}
		
		el.is_mouse_rele = false
	}

	el.HElement.draw(ctx)
	el.debug_draw(el, ctx)
}

// PLACEHOLDER
struct ButtonElement {
	HElement
mut:
	inner_text string
}

fn (mut el ButtonElement) draw(ctx &ui.GraphicsContext) {
	cfg_def := gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	}

	fsr := el.page.styles.get_rule(el.tag.name, 'font-size')

	mut fs := ctx.font_size
	if fsr != none {
		fss := fsr or { '' }

		if fss.contains('em') {
			fs = ctx.font_size * fss.int()
		}

		if fss.contains('px') {
			fs = fss.int()
		}
	}

	cfg := gx.TextCfg{
		size: fs
	}

	ctx.gg.set_text_cfg(cfg)

	if el.inner_text.len > 0 {
		tw := ctx.text_width(el.inner_text)
		el.width = tw
		if tw > 0 {
			el.height = ctx.gg.text_height(el.inner_text)
		}
	}

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.gg.draw_rect_filled(el.x, el.y, el.width, el.height, gx.rgb(230,230,230))
		ctx.gg.draw_rect_empty(el.x, el.y, el.width, el.height, gx.rgb(190, 190, 190))
	
		ctx.draw_text(el.x, el.y, el.inner_text, 0, cfg)
		//ctx.gg.draw_line(el.x, el.y + el.height, el.x + el.width, el.y + el.height, link_color)

		ctx.gg.set_text_cfg(cfg_def)
	}
	
	if el.is_mouse_rele {
		dump('click')
		//href := el.tag.attributes['href']
		
		//dump(href)
		
		//el.page.load(href)
		
		el.is_mouse_rele = false
	}

	el.HElement.draw(ctx)
	el.debug_draw(el, ctx)
}


// PLACEHOLDER
struct CenterElement {
	HElement
mut:
	inner_text string
}

fn (mut el CenterElement) draw(ctx &ui.GraphicsContext) {
	cfg_def := gx.TextCfg{
		size: ctx.font_size
	}

	fsr := el.page.styles.get_rule(el.tag.name, 'font-size')

	mut fs := ctx.font_size
	if fsr != none {
		fss := fsr or { '' }

		if fss.contains('em') {
			fs = int(ctx.font_size * fss.f32())
		}

		if fss.contains('px') {
			fs = fss.int()
		}
	}

	cfg := gx.TextCfg{
		size: fs
	}

	ctx.gg.set_text_cfg(cfg)

	if el.inner_text.len > 0 {
		tw := ctx.text_width(el.inner_text)
		el.width = tw
		if tw > 0 {
			el.height = ctx.gg.text_height(el.inner_text)
		}
	}

	ws := ctx.gg.window_size()

	if !(el.y > ws.height || el.y < 0) {
		ctx.draw_text(el.x, el.y, el.inner_text, 0, cfg)

		ctx.gg.set_text_cfg(cfg_def)
	}

	el.HElement.draw(ctx)
	el.debug_draw(el, ctx)
}