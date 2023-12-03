module main

import iui as ui
import net.http
import net.html
import gg
import gx
import os

@[heap]
struct App {
mut:
	win &ui.Window
	wp  &HPage
}

fn main() {
	mut win := ui.Window.new(
		title: 'Web Browser'
		width: 640
		height: 480
		font_size: 16
	)

	mut app := &App{
		win: win
		wp: unsafe { nil }
	}

	win.bar = ui.Menubar.new()
	win.bar.add_child(ui.MenuItem.new(text: 'File'))
	win.bar.add_child(app.create_link_menu())
	win.bar.add_child(create_theme_menu())

	mut cp := ui.Panel.new(
		layout: ui.BorderLayout.new(hgap: 0, vgap: 0)
	)

	mut navbar := ui.Panel.new(layout: ui.BoxLayout.new(hgap: 5, vgap: 5, ori: 0))

	mut field := ui.text_field(
		text: 'https://example.com/'
	)

	navbar.set_bounds(0, 0, 600, 100)
	navbar.subscribe_event('draw', draw_border)

	field.set_bounds(0, 0, 300, 25)

	mut back_btn := ui.Button.new(text: '<')
	mut for_btn := ui.Button.new(text: '>')

	mut home_btn := ui.Button.new(text: 'Home')
	mut go_btn := ui.Button.new(text: 'Go')
	mut save_btn := ui.Button.new(text: 'Save')

	mut wp := &HPage{
		x: 0
		y: 0
		width: 600
		height: 400
	}
	app.wp = wp
	wp.subscribe_event('draw', draw_wp_border)

	// path := os.resource_abs_path('tests/index.html')
	// wp.load('file://' + path)

	wp.load('https://google.com')

	mut sv := ui.ScrollView.new(
		view: wp
		bounds: ui.Bounds{2, 2, 600, 400}
	)
	sv.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		ws := e.ctx.gg.window_size()
		e.target.width = ws.width - 4
		e.target.height = ws.height - 2 - e.target.y
	})

	go_btn.subscribe_event('mouse_up', fn [mut field, mut wp] (mut e ui.MouseEvent) {
		wp.load(field.text)
	})

	save_btn.subscribe_event('mouse_up', fn [mut wp] (mut e ui.MouseEvent) {
		to_save := os.resource_abs_path('save_output.html')

		os.write_file(to_save, wp.content) or { println(err) }
	})

	navbar.add_child(back_btn)
	navbar.add_child(for_btn)
	navbar.add_child(home_btn)
	navbar.add_child(field)
	navbar.add_child(go_btn)
	navbar.add_child(save_btn)

	cp.add_child_with_flag(navbar, ui.borderlayout_north)
	cp.add_child_with_flag(sv, ui.borderlayout_center)
	win.add_child(cp)

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
	mut theme_menu := ui.MenuItem.new(text: 'Links')

	links := [
		'tests/index.html',
		'tests/test.html',
		'tests/google_bar.html',
		'https://google.com',
		'https://example.com',
		'http://frogfind.com',
		'http://68k.news',
		'http://info.cern.ch',
		'https://old.reddit.com',
		//'https://theoldnet.com/get?url=google.com&year=2004&scripts=false&decode=false'
		//'https://theoldnet.com/get?url=google.com&year=2010&scripts=false&decode=false'
		'https://theoldnet.com/get?url=google.com&year=2015&scripts=false&decode=false',
	]
	for theme in links {
		mut item := ui.MenuItem.new(
			text: theme //.name
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

	e.ctx.gg.draw_rect_empty(e.target.x, e.target.y, e.target.width, e.target.height,
		gx.black)
}

fn draw_border(mut e ui.DrawEvent) {
	ws := e.ctx.gg.window_size()
	e.target.height = 35
	e.target.width = ws.width
	e.ctx.gg.draw_rect_filled(e.target.x, e.target.y, e.target.width, e.target.height,
		gx.rgb(230, 230, 230))

	x := e.target.x
	y := e.target.y

	e.ctx.gg.draw_line(x, y + e.target.height, x + e.target.width, y + e.target.height,
		gx.rgb(170, 170, 170))
}
