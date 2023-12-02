module main

import iui as ui
import net.http
import net.html
import gg
import gx
import os

[heap]
struct App {
mut:
	win &ui.Window
	wp &Webpage
}

fn main() {
	mut win := ui.make_window(
		title: 'Web Browser'
		width: 640
		height: 480
		font_size: 16
	)
	
	mut app := &App{
		win: win,
		wp: unsafe { nil }
	}
	
	win.set_theme(ui.theme_seven())
	
	win.bar = ui.menubar(win, win.theme)
	win.bar.add_child(ui.menu_item(text: 'File'))
	win.bar.add_child(app.create_link_menu())
	win.bar.add_child(create_theme_menu())
	
	
	mut vbox := ui.Panel.new() // ui.vbox(win)
	mut navbar := ui.Panel.new() // ui.hbox(win)
	
	mut field := ui.text_field(
		text: 'https://example.com/'
	)
	
	navbar.set_bounds(0, 0, 600, 100)
	navbar.subscribe_event('draw', draw_border)
	
	field.set_bounds(20, 5, 300, 25)
	vbox.set_bounds(0, 25, 600, 400)

	mut back_btn := ui.button(
		text: '<'
		bounds: ui.Bounds{5, 5, 25, 25}
	)
	
	mut for_btn := ui.button(
		text: '>'
		bounds: ui.Bounds{2, 5, 25, 25}
	)
	
	mut home_btn := ui.button(
		text: 'Home'
		bounds: ui.Bounds{5, 5, 45, 25}
	)

	mut go_btn := ui.button(
		text: 'Go'
		bounds: ui.Bounds{2, 5, 40, 25}
	)

	mut save_btn := ui.button(
		text: 'Save'
		bounds: ui.Bounds{2, 5, 40, 25}
	)
	
	mut wp := &Webpage{
		x: 0
		y: 0
		width: 600
		height: 400
	}
	app.wp = wp
	wp.subscribe_event('draw', draw_wp_border)
	
	path := os.resource_abs_path('tests/index.html')
	wp.load('file://' + path)
	
	mut sv := ui.scroll_view(
		view: wp
		bounds: ui.Bounds{4, 10, 600, 400}
	)
	sv.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		ws := e.ctx.gg.window_size()
		e.target.width = ws.width - 8
		e.target.height = ws.height - e.target.y - 1
	})
	
	go_btn.subscribe_event('mouse_up', fn [mut field, mut wp] (mut e ui.MouseEvent) {
		wp.load(field.text)
	})
		
	save_btn.subscribe_event('mouse_up', fn [mut wp] (mut e ui.MouseEvent) {
		to_save := os.resource_abs_path('save_output.html')
		
		os.write_file(to_save, wp.content) or {
			println(err)
		}
	})
	
	navbar.add_child(back_btn)
	navbar.add_child(for_btn)
	navbar.add_child(home_btn)
	navbar.add_child(field)
	navbar.add_child(go_btn)
	navbar.add_child(save_btn)
	vbox.add_child(navbar)
	vbox.add_child(sv)
	win.add_child(vbox)
	
	win.gg.run()
}

// Make a 'Theme' menu item to select themes
fn create_theme_menu() &ui.MenuItem {
	mut theme_menu := ui.menuitem('Themes')

	themes := ui.get_all_themes()
	for theme in themes {
		item := ui.menu_item(
			text: theme.name
			click_event_fn: theme_click
		)
		theme_menu.add_child(item)
	}
	return theme_menu
}


fn (mut app App) create_link_menu() &ui.MenuItem {
	mut theme_menu := ui.menuitem('Links')

	links := [
		'tests/index.html',
		'tests/test.html',
		'tests/google_bar.html',
		'https://google.com'
		'https://example.com'
		'http://frogfind.com'
		'http://68k.news'
		'http://info.cern.ch'
		'https://old.reddit.com'
		//'https://theoldnet.com/get?url=google.com&year=2004&scripts=false&decode=false'
		//'https://theoldnet.com/get?url=google.com&year=2010&scripts=false&decode=false'
	]
	for theme in links {
		mut item := ui.menu_item(
			text: theme//.name
			click_event_fn: app.link_menu_click
		)
		
		theme_menu.add_child(item)
	}
	return theme_menu
}

fn (mut app App) link_menu_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	app.wp.load(text)
}



// MenuItem in the Theme section click event
fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn draw_wp_border(mut e ui.DrawEvent) {
	if !e.ctx.win.debug_draw {
		return
	}

	e.ctx.gg.draw_rect_empty(e.target.x, e.target.y, e.target.width, e.target.height, gx.black)
}

fn draw_border(mut e ui.DrawEvent) {
	ws := e.ctx.gg.window_size()
	e.target.height = 35
	e.target.width = ws.width
	e.ctx.gg.draw_rect_filled(e.target.x, e.target.y, e.target.width, e.target.height, gx.rgb(230,230,230))
	
	x := e.target.x
	y := e.target.y
	
	e.ctx.gg.draw_line(x, y + e.target.height, x + e.target.width, y + e.target.height, gx.rgb(170, 170, 170))
}

struct Layout {
mut:
	page &Webpage
	x int
	y int
	h int
	rh int
}

struct HTMLElement {
	ui.Component_A
mut:
	layout &Layout
	parent_element &HTMLElement
	inner_text string
	display    string
	tag &html.Tag
	//kids []&ui.Component
	ui_elm &ui.Component //= unsafe { nil }
	kids []&HTMLElement
}

const (
	block_tags = [
		"address", "article", "aside", "abody", "dd", "details", "div", "dl", "dt",
		"fieldset", "figcaption", "figure", "form", "h1", "h2", "h3", "h4", "h5", "h6",
		"hr", "header", "htmla", "iframe", "legend", "menu",
		"nav", "ol", "p", "pre", "section", "summary", "ul","li"
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
		return  int(vall)
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
	
	if tag_name == 'meta' || tag_name == 'style' || tag_name == 'head' || tag_name == 'text' || tag_name == 'script' {
		return
	}

	dn := ''
	bh := 0 

	mut tw := ctx.text_width(this.inner_text.trim(' '))

	if tag_name == 'img' {
		//this.inner_text = this.tag.attributes['src'] or { 'IMG ALT' }
		//this.layout.page.follow_url(this.inner_text)
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
			ctx.gg.draw_rect_filled(x, y, tw, hei, gx.rgb(230,230,230))
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
		//mut cel := this.kids[i]
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
	url string
	content string
	kids []&HTMLElement
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
		
		/*if tag.name == 'img' {
			this.ui_elm = this.layout.page.handle_image(mut this.layout.page.)
		}*/
		
		/*el.subscribe_event('draw', fn [mut el] (mut e ui.MouseEvent) {
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
			//el.ui_elm = el.layout.page.handle_image(el.tag)
			//el.add_child(el.ui_elm)
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

		//x += child.width
		y += child.height
	}
	this.height = y - this.y
}

fn (mut this Webpage) follow_url(url string) {

} 