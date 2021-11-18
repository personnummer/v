module personnummer

import time
import math

// Test if the given string is a valid luhn string.
fn luhn(str string) int {
	mut sum := 0

	for i, s in str {
		mut v := s.ascii_str().int()

		v *= 2 - (i % 2)

		if v > 9 {
			v -= 9
		}

		sum += v
	}

	return int(math.pow(math.ceil(math.round(sum)/10)*10 - sum, 1.0))
}

// Test if the input parameters are a valid date or not.
fn test_date(year string, month string , day string) bool {
	y := year.int()
	m := month.int()
	dd := day.int()
	d := time.parse('$year-$month-$day 00:00:00') or {
		return false
	}
	return d.year == y && d.month == m && d.day == dd
}

// Personnummer represents the personnummer struct.
struct Personnummer {
	mut:
	century             string
	full_year           string
	year                string
	month               string
	day                 string
	sep                 string
	num                 string
	check               string
}

// // Options represents the personnummer options.
// struct Options {
// }

// New parse a Swedish personal identity numbers and returns a new struct or a error.
pub fn new(pin string) ?Personnummer {
	mut p := Personnummer{}

	p.parse(pin) or {
		return error('parse error')
	}

	if !p.valid() {
		return error('new error')
	}

	return p
}

// Format a Swedish personal identity number as one of the official formats,
// A long format or a short format.
pub fn (p Personnummer) format(longFormat bool) string {
	if longFormat {
		return p.century + p.year + p.month + p.day + p.num + p.check
	}

	return p.year + p.month + p.day + p.sep + p.num + p.check
}

// Check if a Swedish personal identity number is for a female.
pub fn (p Personnummer) is_female() bool {
	return !p.is_male()
}

// Check if a Swedish personal identity number is for a male.
pub fn (p Personnummer) is_male() bool {
	sex_digit := p.num[2 .. 3].int()
	return sex_digit % 2 == 1
}

// Check if a Swedish personal identity number is a coordination number or not.
pub fn (p Personnummer) is_coordination_number() bool {
	return test_date(p.full_year, p.month, (p.day.int()-60).str())
}

// Get age from a Swedish personal identity number.
pub fn (p Personnummer) get_age() int {
	mut age_day := p.day
	if p.is_coordination_number() {
		age_day = (age_day.int() - 60).str()
	}

	now := time.now()
	date := time.parse('$p.full_year-$p.month-$age_day 00:00:00') or {
		return 0
	}

	if date.month > now.month {
		return now.year - date.year - 1
	}

	if date.month == now.month && date.day > now.day {
		return now.year - date.year - 1
	}

	return now.year - date.year
}

// Parse Swedish personal identity numbers and set struct properpties or return a error.
fn (mut p Personnummer) parse(input string) ?bool {
	mut pin := input

	plus := pin.contains('+')

	pin = pin.replace('+', '')
	pin = pin.replace('-', '')

	if pin.len == 12 {
		p.century = pin[0..2]
		p.year = pin[2 .. 4]
		p.month = pin[4 .. 6]
		p.day = pin[6 .. 8]
		p.num = pin[8 .. 11]
		p.check = pin[11 .. 12]
	} else if pin.len == 10 {
		p.year = pin[0..2]
		p.month = pin[2 .. 4]
		p.day = pin[4 .. 6]
		p.num = pin[6 .. 9]
		p.check = pin[9 .. 10]
	} else {
		return error('Invalid swedish personal identity number')
	}

	if p.num == '000' {
		return error('Invalid swedish personal identity number')
	}

	p.sep = '-'

	current_time := time.now()

	if p.century.len == 0 {
		mut base_year := current_time.year

		if plus {
			p.sep = '+'
			base_year -= 100
		}

		p.century = (base_year - (base_year - p.year.int()) % 100).str()[0..2]
	} else {
		if current_time.year - (p.century + p.year).int() < 100 {
			p.sep = '-'
		} else {
			p.sep = '+'
		}
	}

	p.full_year = p.century + p.year

	return true
}

// Validate a Swedish personal identity number.
pub fn (p Personnummer) valid() bool {
	valid := luhn(p.year + p.month + p.day + p.num) == p.check.int()

	if valid && test_date(p.full_year, p.month, p.day) {
		return true
	}

	return valid && p.is_coordination_number()
}