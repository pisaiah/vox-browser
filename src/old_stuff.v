module main

import iui as ui
import net.html

const (
	block_tags = [
		'address',
		'article',
		'dd',
		'details',
		'div',
		'dl',
		'dt',
		'fieldset',
		'figcaption',
		'figure',
		'form',
		'hr',
		'header',
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
