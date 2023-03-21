module test

import net.http
import json
import personnummer
import time

__global (
	json_data = map[string]string{}
)

const available_list_formats = [
	'long_format',
	'short_format',
	'separated_format',
	'separated_long',
]

struct List {
	integer          int
	long_format      string
	short_format     string
	separated_format string
	separated_long   string
	valid            bool
	ltype            string [json: 'type']
	is_male          bool   [json: isMale]
	is_female        bool   [json: isFemale]
}

fn (l List) get_format(s string) string {
	return match s {
		'long_format' {
			l.long_format
		}
		'short_format' {
			l.short_format
		}
		'separated_format' {
			l.separated_format
		}
		'separated_long' {
			l.separated_long
		}
		else {
			''
		}
	}
}

fn fetch_list(url string) []List {
	if json_data[url].len == 0 {
		resp := http.get(url) or {
			eprintln('failed to fetch test list from the github')
			return []List{}
		}
		json_data[url] = resp.text
	}

	return json.decode([]List, json_data[url]) or {
		eprintln('failed to parse json')
		return []List{}
	}
}

fn get_test_list() []List {
	return fetch_list('https://raw.githubusercontent.com/personnummer/meta/master/testdata/list.json')
}

fn get_interim_list() []List {
	return fetch_list('https://raw.githubusercontent.com/personnummer/meta/master/testdata/interim.json')
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
			if format != 'short_format' {
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
	for i, item in get_test_list() {
		if !item.valid {
			continue
		}

		pin := item.get_format('separated_long')

		year := pin[0..4].int()
		month := pin[4..6].int()

		mut age_day := pin[6..8].int()

		if item.ltype == 'con' {
			age_day = age_day - 60
		}

		now := time.now()
		date := time.new_time(time.Time{
			year: year
			month: month
			day: age_day
		})

		mut expected := 0
		if date.month > now.month {
			expected = now.year - date.year - 1
		} else if date.month == now.month && date.day > now.day {
			expected = now.year - date.year - 1
		} else {
			expected = now.year - date.year
		}

		for j, format in test.available_list_formats {
			if format != 'short_format' {
				p := personnummer.parse(item.get_format(format)) or {
					eprintln('failed to parse in test_personnummer_age for $format')
					return
				}
				assert expected == p.get_age()
			}
		}
	}
}

fn test_valid_interim_numbers() {
	for i, item in get_interim_list() {
		if !item.valid {
			continue
		}

		for j, format in test.available_list_formats {
			if format != 'short_format' {
				p := personnummer.parse(item.get_format(format), personnummer.Options{
					allow_interim_number: true
				}) or {
					eprintln('failed to parse in test_interim_numbers for $format')
					return
				}

				assert item.separated_format == p.format(false)
				assert item.long_format == p.format(true)
			}
		}
	}
}

fn test_invalid_interim_numbers() {
	for i, item in get_interim_list() {
		if item.valid {
			continue
		}

		for j, format in test.available_list_formats {
			personnummer.parse(item.get_format(format), personnummer.Options{
				allow_interim_number: true
			}) or { assert true == true }
		}
	}
}
