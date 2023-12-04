module main

import iui as ui
import net.html

const (
	block_tags = [
		'address',
		'article',
		'aside',
		'abody',
		'dd',
		'details',
		'div',
		'dl',
		'dt',
		'fieldset',
		'figcaption',
		'figure',
		'form',
		'h1',
		'h2',
		'h3',
		'h4',
		'h5',
		'h6',
		'hr',
		'header',
		'htmla',
		'iframe',
		'legend',
		'menu',
		'nav',
		'ol',
		'p',
		'pre',
		'section',
		'summary',
		'ul',
		'li',
		'table',
		'tr',
		'center',
	]
)

// old web engine
@[deprecated: 'Old']
struct LayoutOld {
mut:
	// page &Webpage
	x  int
	y  int
	h  int
	rh int
}

fn (mut this HElement) get_font_size(tn string) int {
	// defaults:
	// h1 = 2em
	// h2 = 1.5em
	// h3 = 1.17em
	// h4 = 1em
	// h5 = .83em
	// h6 = .67em
	rem := f32(16.0)
	val := match tn {
		'h1' { 2 * rem }
		'h2' { 1.5 * rem }
		'h3' { 1.17 * rem }
		'h4' { 1 * rem }
		else { rem }
	}
	if tn == 'font' {
		attr := this.tag.attributes['size']
		vall := match attr {
			'7' { 3 * rem }
			'6' { 2 * rem }
			'5' { 1.5 * rem }
			'4' { 1.13 * rem }
			'3' { 1 * rem }
			'2' { .82 * rem }
			'1' { .63 * rem }
			else { rem }
		}
		return int(vall)
	}
	return int(val)
}

/*
fn (mut this HTMLElement) draw(ctx &ui.GraphicsContext) {
	tag_name := this.tag.name.to_lower()

	if tag_name == 'html' {
		this.layout.x = 8 // Default CSS = margin: 8px
		this.layout.y = 8
		this.layout.rh = 0
	}

	if tag_name == 'meta' || tag_name == 'style' || tag_name == 'head' || tag_name == 'text'
		|| tag_name == 'script' {
		return
	}

	dn := ''
	bh := 0

	mut tw := ctx.text_width(this.inner_text.trim(' '))

	ctx.gg.set_text_cfg(gx.TextCfg{
		size: this.get_font_size(tag_name)
	})
	lh := ctx.gg.text_height(this.inner_text.trim(' '))

	if tag_name in block_tags {
		this.layout.x = 8 // default margin
		this.layout.y += this.layout.rh
		this.layout.h = 0
		this.layout.rh = 0
	}

	mut x := this.layout.x + this.layout.page.x
	mut y := this.layout.y + this.layout.page.y

	this.x = x
	this.y = y

	ws := ctx.gg.window_size()

	mut hei := lh

	if hei > this.layout.h {
		this.layout.h = hei + 5
	}

	this.width = tw
	this.height = hei

	if y < ws.height && y > 0 {
		if tag_name == 'button' {
			ctx.gg.draw_rect_filled()
			ctx.gg.draw_rect_empty()
		}

		ctx.draw_text(x, y, this.inner_text, ctx.font, gx.TextCfg{
			color: gx.black
			size: this.get_font_size(tag_name)
		})
	}

	if this.layout.rh < hei {
		this.layout.rh = hei
	}

	for i, mut child in this.children {
		child.draw_with_offset(ctx, x, y)
	}

	if tag_name == '!doctype' {
		this.width = this.layout.x + 50
		this.height = this.layout.y + 150
		return
	}

	this.width = tw
	this.height = hei // y - this.y
	if tag_name in block_tags {
		this.width = 620
	}

	this.layout.x += tw

	if tag_name in block_tags {
		this.layout.y += hei + 5
		this.layout.x = 8 // default margin: 8px
	}
}
*/
