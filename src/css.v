// Copyright (c) 2023 Isaiah.
module main

// StyleSheet
struct StyleSheet {
mut:
	rules map[string]Properties
}

struct Properties {
mut:
	values map[string]string
}

pub fn StyleSheet.new() &StyleSheet {
	return &StyleSheet{}
}

pub fn (mut this StyleSheet) clear() {
	this.rules.clear()
	this.rules = map[string]Properties{}
}

pub fn (mut this StyleSheet) parse(content []string) {
	mut val := ''
	for s in content {
		if s.contains('{') {
			mut nam := s.split('{')[0].trim_space()
			val = nam
			dump(nam)
		}

		if s.contains(':') {
			a := s.split(':')[0].trim_space()
			b := s.split(':')[1].trim_space()

			this.set_rule(val, a, b)
		}
	}
}

pub fn (mut this StyleSheet) get_rule(selector string, prop string) ?string {
	if selector in this.rules {
		val := this.rules[selector].values[prop]
		if val.len == 0 {
			return none
		}
		return val.replace(';', '')
	}
	return none
}

pub fn (mut this StyleSheet) set_rule(selector string, prop string, val string) {
	if selector !in this.rules {
		this.rules[selector] = Properties{}
	}

	dump('${selector} ${prop} ${val}')
	this.rules[selector].values[prop] = val
}


pub fn (mut this StyleSheet) get_rule_num(selector string, prop string, em int) ?int {
	if selector in this.rules {
		val := this.rules[selector].values[prop]

		if val.contains('em') {
			return int(em * val.f32())
		}

		if val.contains('px') {
			return val.int()
		}
		
		
		if val.len == 0 {
			return none
		}
		return val.int() // .replace(';', '')
	}
	return none
}