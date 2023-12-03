module main

import iui as ui
import net.http
import net.html
import os
import time

struct HPage {
	ui.Component_A
mut:
	status  string
	url     string
	content string
	kids    []&HElement
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

fn (mut el HElement) draw(ctx &ui.GraphicsContext) {
	// test
	// dump('H DRAW')
	ctx.draw_text(el.x, el.y, el.inner_text, 0)
	el.draw_kids(ctx)
}

fn (mut this HElement) draw_kids(ctx &ui.GraphicsContext) {
	mut x := this.x
	mut y := this.y

	for i, mut child in this.children {
		child.draw_with_offset(ctx, x, y)

		// x += child.width
		// dump(child.height)
		y += child.height
	}

	if y - this.y > 0 {
		this.height = y - this.y
	}
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

	if nam == 'script' || nam == '!doctype' {
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
			inner_text: tag.content
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'meta' {
		mut el := &MetaElement{
			tag: tag
			inner_text: tag.content
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'style' {
		mut el := &StyleElement{
			tag: tag
			inner_text: tag.content
			page: this
		}
		el.add_kids()
		return el
	}

	if nam == 'img' {
		mut el := &ImgElement{
			tag: tag
			inner_text: tag.content
			page: this
			img: unsafe { nil }
		}
		el.add_kids()
		return el
	}

	mut el := &TextElement{
		tag: tag
		inner_text: tag.content
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
