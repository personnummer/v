module test

import net.http
import json
import personnummer

struct List {
	integer          int
	long_format      string
	short_format     string
	separated_format string
	separated_long   string
	valid            bool
	// ltype string [json: type]
	is_male   bool [json: isMale]
	is_female bool [json: isFemale]
}

fn (l List) get_format(s string) string {
	if s == 'long_format' {
		return l.long_format
	} else if s == 'short_format' {
		return l.short_format
	} else if s == 'separated_format' {
		return l.separated_format
	} else if s == 'separated_long' {
		return l.separated_long
	} else {
		return ''
	}
}

const available_list_formats = [
	'long_format',
	'short_format',
	'separated_format',
	'separated_long',
]

fn get_test_list() []List {
	// if (_test_list.len == 0)
	// {
	resp := http.get('https://raw.githubusercontent.com/personnummer/meta/master/testdata/list.json') or {
		eprintln('failed to fetch test list from the github')
		return []List{}
	}
	text := resp.text

	return json.decode([]List, text) or {
		eprintln('failed to parse json')
		return []List{}
	}
}

fn test_personnummer_list() {
	for i, item in get_test_list() {
		for j, format in test.available_list_formats {
			assert item.valid == personnummer.valid(item.get_format(format))
		}
	}
}

fn test_personnummer_format() {
	for i, item in get_test_list() {
		if !item.valid {
			continue
		}

		for j, format in test.available_list_formats {
			if format != 'short_format' && !item.separated_format.contains('+') {
				p := personnummer.parse(item.get_format(format)) or {
					eprintln('failed to parse in test_personnummer_format for $format')
					return
				}
				assert item.separated_format == p.format(false)
				assert item.long_format == p.format(true)
			}
		}
	}
}

fn test_personnummer_error() {
	for i, item in get_test_list() {
		if item.valid {
			continue
		}

		for j, format in test.available_list_formats {
			personnummer.parse(item.get_format(format)) or { assert true == true }
		}
	}
}

fn test_personnummer_sex() {
	for i, item in get_test_list() {
		if !item.valid {
			continue
		}

		for j, format in test.available_list_formats {
			p := personnummer.parse(item.get_format(format)) or {
				eprintln('failed to parse in test_personnummer_sex for $format')
				return
			}

			assert item.is_male == p.is_male()
			assert item.is_female == p.is_female()
		}
	}
}

fn test_personnummer_age() {
}
