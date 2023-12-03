module main

import iui as ui
import net.html
import net.http
import os
import encoding.base64

// NOTE: OLD

fn (page &HPage) handle_image(tag &html.Tag) &ui.Image {
	dump('HANDLE IMAGE')

	src := tag.attributes['src']

	tmp := os.temp_dir()
	cache := os.real_path(tmp + '/v-browser-cache/')
	os.mkdir(cache) or {}

	mut w := -1
	mut h := 10

	if 'width' in tag.attributes {
		w = tag.attributes['width'].int()
	}

	if 'height' in tag.attributes {
		h = tag.attributes['height'].int()
	}

	if src.starts_with('data:') && src.contains('base64') {
		// Base64 encoded image
		encoded := src.split('base64,')[1]

		decode_str := base64.decode_str(encoded)
		out := os.real_path(cache + '/base64-' + os.base(encoded) + '.png')
		os.write_file(out, decode_str) or {}

		gg_img := ui.image_from_file(out)
		/*
		if w == -1 {
			w = gg_img.width
			h = gg_img.height
		}

		img := ui.image_with_size(win, gg_img, w, h)*/

		return gg_img
	}

	fixed_src := format_url(src, page.url)

	mut out := os.real_path(cache + '/' + os.base(fixed_src).replace(':', '_'))

	println('Loading image: ' + fixed_src)

	if os.exists(fixed_src) {
		// Local file
		out = fixed_src
	} else {
		http.download_file(fixed_src, out) or {
			println(err)
			http.download_file(fixed_src.replace('https://', 'https://www.'), out) or {}
		}
	}

	/*
	gg_img := win.gg.create_image(out)
	if w == -1 {
		w = gg_img.width
		h = gg_img.height
	}*/

	// img := ui.image_with_size(win, gg_img, w, h)
	img := ui.image_from_file(out)

	return img
}

// Eg: /test -> https://example.com/test
fn format_url(ref string, page_url string) string {
	mut href := ref

	if href.starts_with('./') {
		href = href.replace('./', '/')
	}

	if !(href.starts_with('http://') || href.starts_with('https://')) {
		// Not-Absolute URL
		if page_url.starts_with('file://') {
			return os.dir(page_url.split('file://')[1]) + '/' + href
		}

		if href.starts_with('/') {
			// Root
			test := page_url.split('?')[0].split('#')[0]
			href = test.split('//')[0] + '//' + test.split('//')[1].split('/')[0] + '/' + href
		} else {
			href = page_url.split('?')[0].split('#')[0] + '/' + href // TODO: handle prams.
		}
	}

	return href
}
