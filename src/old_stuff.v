module main

import iui as ui
import net.http
import net.html
import gg
import gx
import os

// old web engine
struct Layout {
mut:
	page &Webpage
	x    int
	y    int
	h    int
	rh   int
}

struct HTMLElement {
	ui.Component_A
mut:
	layout         &Layout
	parent_element &HTMLElement
	inner_text     string
	display        string
	tag            &html.Tag
	// kids []&ui.Component
	ui_elm &ui.Component
	//= unsafe { nil }
	kids []&HTMLElement
}

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
	]
)

fn (mut this HTMLElement) get_font_size(tn string) int {
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

	if tag_name == 'img' {
		// this.inner_text = this.tag.attributes['src'] or { 'IMG ALT' }
		// this.layout.page.follow_url(this.inner_text)
	}

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

	if this.ui_elm != unsafe { nil } && tag_name == 'img' {
	}

	if hei > this.layout.h {
		this.layout.h = hei + 5
	}

	this.width = tw
	this.height = hei

	if y < ws.height && y > 0 {
		if tag_name == 'button' {
			ctx.gg.draw_rect_filled(x, y, tw, hei, gx.rgb(230, 230, 230))
			ctx.gg.draw_rect_empty(x, y, tw, hei, gx.rgb(190, 190, 190))
		}

		ctx.draw_text(x, y, this.inner_text, ctx.font, gx.TextCfg{
			color: gx.black
			size: this.get_font_size(tag_name)
		})

		if ctx.win.debug_draw {
			ntn := this.tag.name
			ntw := ctx.text_width(ntn)

			ctx.gg.draw_rect_filled(x, y, ntw, hei, gx.rgba(0, 0, 0, 170))

			ctx.draw_text(x, y, this.tag.name, ctx.font, gx.TextCfg{
				color: gx.red
				size: ctx.font_size
			})
		}
	}

	if this.layout.rh < hei {
		this.layout.rh = hei
	}

	for i, mut child in this.children {
		// mut cel := this.kids[i]
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

struct Webpage {
	ui.Component_A
mut:
	url     string
	content string
	kids    []&HTMLElement
}

fn (mut this HTMLElement) load_kids() {
	for tag in this.tag.children {
		mut el := &HTMLElement{
			layout: this.layout
			parent_element: this
			inner_text: tag.content.replace('\n', '')
			ui_elm: unsafe { nil }
			width: 0
			height: 0
			tag: tag
		}

		/*
		if tag.name == 'img' {
			this.ui_elm = this.layout.page.handle_image(mut this.layout.page.)
		}*/

		/*
		el.subscribe_event('draw', fn [mut el] (mut e ui.MouseEvent) {
			if el.tag.name == 'img' {
				//if el.ui_elm == unsafe { nil } {
				unsafe {
					el.ui_elm = el.layout.page.handle_image(mut e.ctx.win, el.tag)
					el.add_child(el.ui_elm)
					}
			//	}
			}
		})*/

		if tag.name == 'img' {
			// el.ui_elm = el.layout.page.handle_image(el.tag)
			// el.add_child(el.ui_elm)
			el.load_as_img()
		}

		el.subscribe_event('mouse_up', fn [mut el] (mut e ui.MouseEvent) {
			dump(el.inner_text.runes())
		})

		el.subscribe_event('draw', draw_wp_border)
		el.load_kids()
		this.kids << el
		this.add_child(el)
	}
}

fn (mut this HTMLElement) load_as_img() {
	this.ui_elm = this.layout.page.handle_image(this.tag)
	this.add_child(this.ui_elm)
}

fn (mut this Webpage) load(url string) {
	this.children.clear()
	this.kids.clear()
	this.url = url

	config := http.FetchConfig{
		user_agent: 'vbrowser/0.1 V/0.3.3'
	}

	mut resp := http.Response{}

	is_file := os.exists(url)

	if url.starts_with('http') {
		fixed_url := if url.contains('://') { url } else { 'http://' + url }

		resp = http.fetch(http.FetchConfig{ ...config, url: fixed_url }) or {
			println('failed to fetch data from the server')
			return
		}
	} else {
		apath := os.resource_abs_path(url)

		path := if os.exists(url) {
			url
		} else if os.exists(apath) {
			apath
		} else {
			url.split('file://')[1]
		}

		lines := os.read_lines(os.real_path(path)) or { [] }
		resp.body = lines.join('\n')
	}

	// TODO: Frogfind uses broken HTML (?)
	fixed_text := resp.body.replace('Find!</font></a></b>', 'Find!</font></b></a>').replace('<p> </small></p>',
		'<p></p>')

	this.content = fixed_text

	doc := html.parse(fixed_text)
	tag := doc.get_root()

	mut el := &HTMLElement{
		layout: &Layout{
			page: this
			x: 0
			y: 0
		}
		parent_element: unsafe { nil }
		ui_elm: unsafe { nil }
		inner_text: tag.content.replace('\n', '')
		width: 10
		height: 2000
		tag: tag
	}
	el.subscribe_event('mouse_up', fn [mut el] (mut e ui.MouseEvent) {
		dump(el.inner_text.runes())
	})

	el.subscribe_event('draw_after', draw_wp_border)
	el.load_kids()
	this.kids << el
	this.add_child(el)
}

fn (mut this Webpage) draw(ctx &ui.GraphicsContext) {
	mut x := this.x
	mut y := this.y

	mut win := ctx.win

	for i, mut child in this.children {
		child.draw_with_offset(ctx, x, y)

		// x += child.width
		y += child.height
	}
	this.height = y - this.y
}

fn (mut this Webpage) follow_url(url string) {
}
