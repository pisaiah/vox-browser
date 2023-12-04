module main

import iui as ui
import net.http
import net.html
import os
import time
import gx

struct Layout {
mut:
	// page &Webpage
	x  int
	y  int
	h  int
	rh int
}

struct HPage {
	ui.Component_A
mut:
	status    string
	url       string
	content   string
	kids      []&HElement
	layout    &Layout
	debug     bool
	debug_dat string = ''
	styles    &StyleSheet
}

struct HElement {
	ui.Component_A
mut:
	page       &HPage
	inner_text string
	tag        &html.Tag
	kids       []voidptr
	//&HElement
}

pub fn (com &HElement) debug_draw(comm &ui.Component, ctx &ui.GraphicsContext) {
	if !com.page.debug {
		return
	}

	tn := comm.type_name().replace('Element', '')
	txt := tn + ' / ${com.tag.name}' // comm.type_name().replace('Element', '')

	if com.tag.name != tn.to_lower() {
		println('Missing Tag Impl: ${com.tag.name}, Currently: ${tn}')
	}

	if !com.page.debug_dat.contains(txt) && com.page.debug_dat.len > 0 {
		return
	}

	tw := ctx.text_width(txt)
	tx := com.x + (com.width / 2) - (tw / 2)
	ty := com.y + (com.height / 2) - (ctx.line_height / 2)

	x2 := com.x + com.width
	y2 := com.y + com.height

	ctx.gg.draw_rect_filled(tx, ty, tw, ctx.line_height, gx.rgba(250, 0, 0, 255))

	ctx.draw_text(tx, ty, txt, 0)

	ctx.gg.draw_rect_empty(com.x, com.y, com.width, com.height, gx.red)
}

fn (mut el HElement) draw(ctx &ui.GraphicsContext) {
	bg := el.page.styles.get_rule(el.tag.name, 'background')

	if bg != none {
		dump('${el.tag.name} ${bg}')
		val := bg or { '' }

		if val.contains('rgb') {
			spl := val.split('(')[1].split(')')[0].split(',')
			color := gx.rgb(spl[0].u8(), spl[1].u8(), spl[2].u8())
			// dump('${el.width} ${el.height}')
			ctx.gg.draw_rect_filled(el.x, el.y, el.width, el.height, color)
		}
	}

	el.draw_kids(ctx)
}

fn (mut this HElement) draw_kids(ctx &ui.GraphicsContext) {
	this.page.layout.rh = 0

	mut rh := 0

	xx := if this.tag.name == 'center' {
		// dump(this.width)
		this.x // + (this.page.width / 2) - (this.width / 2)
	} else {
		this.x
	}

	mut x := xx
	mut y := this.y

	for i, mut child in this.children {
		if this.tag.children.len <= i {
			continue
		}

		tag_name := this.tag.children[i].name

		cc := child.children.len

		if tag_name in block_tags {
			// this.page.layout.x = 8 // default margin
			// this.page.layout.y += this.page.layout.rh
			// this.page.layout.h = 0

			// this.page.layout.h = 0
			child.width = this.page.width

			y += rh // this.page.layout.rh
			x = xx
			rh = 0
		} else {
			if child.height > rh {
				rh = child.height // + 5
			}
		}

		child.draw_with_offset(ctx, x, y)

		if child.height > rh {
			rh = child.height // + 5
		}

		if tag_name in block_tags {
			y += child.height
			rh = 0
		} else {
			x += child.width
		}
	}

	if y - this.y > 0 {
		this.height = y - this.y
	} else {
		if rh > 0 {
			this.height = rh
		}
	}

	if this.width == 0 {
		this.width = x - xx
	}
	// dump(this.width)

	// dump(this.height)
}

fn ft(s string) string {
	if s.len > 50 {
		return s[0..20]
	}
	return s
}

fn (mut this HPage) load(url string) {
	start := time.now()
	this.status = 'Loading "${url}"...'
	this.children.clear()
	this.kids.clear()
	this.url = url
	this.styles.clear()

	default_css := os.read_lines(os.resource_abs_path('src/assets/default.css')) or { [''] }
	this.styles.parse(default_css)

	config := http.FetchConfig{
		user_agent: 'VBrowser/0.1 V/0.4.3'
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

	an := time.now()

	// TODO: Frogfind uses broken HTML (?)
	fixed_text := resp.body.replace('Find!</font></a></b>', 'Find!</font></b></a>').replace('<p> </small></p>',
		'<p></p>')

	this.content = fixed_text

	doc := html.parse(fixed_text)
	tag := doc.get_root()

	mut el := this.make_element_from_tag(tag)
	this.add_child(el)

	end := time.now()
	took := end - start

	this.status = 'Done. | Total=${took} Render=${end - an} | VBrowser/0.1 '
}

fn (mut this HPage) draw(ctx &ui.GraphicsContext) {
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

fn (mut this HPage) follow_url(url string) {
}

fn (mut this HPage) make_elements(root &html.Tag) {
	mut el := &HElement{
		tag: root
		page: this
	}

	for tag in root.children {
		el.kids << this.make_element_from_tag(tag)
	}

	// dump(el)
	this.add_child(el)
}

fn (mut this HPage) make_element_from_tag(tag &html.Tag) &ui.Component {
	println('MAKE EL: ${tag.name}')
	this.status = 'Making ${tag.name} ...'

	nam := tag.name
	con := tag.content.trim_space()

	if nam == 'script' || nam == '!doctype' || nam == 'title' {
		mut el := &EmptyElement{
			tag: tag
			inner_text: tag.content
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'html' {
		mut el := &HtmlElement{
			tag: tag
			inner_text: con
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'meta' {
		mut el := &MetaElement{
			tag: tag
			inner_text: con
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'style' {
		mut el := &StyleElement{
			tag: tag
			inner_text: con
			page: this
		}

		dump(con)
		this.styles.parse(con.split_into_lines())

		el.add_kids()
		return el
	}

	if nam == 'img' {
		mut el := &ImgElement{
			tag: tag
			inner_text: con
			page: this
			img: unsafe { nil }
		}
		el.add_kids()
		return el
	}

	if nam == 'input' {
		mut el := &InputElement{
			tag: tag
			inner_text: con
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'body' {
		mut el := &BodyElement{
			tag: tag
			inner_text: con
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'div' {
		mut el := &DivElement{
			tag: tag
			inner_text: con
			page: this
		}
		el.add_kids()
		return el
	}

	mut el := &TextElement{
		tag: tag
		inner_text: con
		page: this
	}
	el.add_kids()

	return el
}

fn (mut el HElement) add_kids() {
	for tagg in el.tag.children {
		ell := el.page.make_element_from_tag(tagg)
		el.kids << ell
		el.add_child(ell)
	}
}
