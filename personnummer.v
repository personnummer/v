module personnummer

import time
import math

const err_invalid_number = error('Invalid swedish personal identity number')

// luhn will test if the given string is a valid luhn string.
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

	return int(math.pow(math.ceil(math.round(sum) / 10) * 10 - sum, 1.0))
}

// validate_date if the input parameters are a valid date or not.
fn validate_date(year string, month string, day string) bool {
	y := year.int()
	m := month.int()
	dd := day.int()

	d := time.new_time(time.Time{
		year: y
		month: m
		day: dd
	})

	return d.year == y && d.month == m && d.day == dd
}

// personnummer represents the personnummer struct.
struct Personnummer {
mut:
	century   string
	full_year string
	year      string
	month     string
	day       string
	sep       string
	num       string
	check     string
}

// options represents the personnummer options.
pub struct Options {
}

type Any = Options | string

// new parse a Swedish personal identity numbers and returns a new struct or a error.
pub fn new(args ...Any) ?Personnummer {
	return parse(...args) or { return personnummer.err_invalid_number }
}

// parse function will parse a Swedish personal identity numbers and returns a new struct or a error.
pub fn parse(args ...Any) ?Personnummer {
	pin := (args[0] as string).clone()

	// -- Save for later when options is a thing.
	// mut options := Options{}
	// if args.len > 1 {
	// 	options = args[1] as Options
	// }

	mut p := Personnummer{}

	p.parse(pin) or { return personnummer.err_invalid_number }

	return p
}

// valid validates a Swedish personal identity number.
pub fn valid(pin string) bool {
	p := parse(pin) or { return false }

	return p.valid()
}

// format will format a Swedish personal identity number as one of
// the official formats, long format or a short format.
pub fn (p Personnummer) format(longFormat bool) string {
	if longFormat {
		return p.century + p.year + p.month + p.day + p.num + p.check
	}

	return p.year + p.month + p.day + p.sep + p.num + p.check
}

// is_female will check if a Swedish personal identity number is for a female.
pub fn (p Personnummer) is_female() bool {
	return !p.is_male()
}

// is_male will check if a Swedish personal identity number is for a male.
pub fn (p Personnummer) is_male() bool {
	sex_digit := p.num[2..3].int()
	return sex_digit % 2 == 1
}

// is_coordination_number will check if a Swedish personal identity number
// is a coordination number or not.
pub fn (p Personnummer) is_coordination_number() bool {
	return validate_date(p.full_year, p.month, (p.day.int() - 60).str())
}

// get_age will return the age from a Swedish personal identity number.
pub fn (p Personnummer) get_age() int {
	mut age_day := p.day
	if p.is_coordination_number() {
		age_day = (age_day.int() - 60).str()
	}

	now := time.now()
	date := time.new_time(time.Time{
		year: p.full_year.int()
		month: p.month.int()
		day: age_day.int()
	})

	if date.month > now.month {
		return now.year - date.year - 1
	}

	if date.month == now.month && date.day > now.day {
		return now.year - date.year - 1
	}

	return now.year - date.year
}

// parse a Swedish personal identity numbers and set struct properpties or return a error.
fn (mut p Personnummer) parse(input string) ?bool {
	mut pin := input

	plus := pin.contains('+')

	pin = pin.replace('+', '')
	pin = pin.replace('-', '')

	if pin.len == 12 {
		p.century = pin[0..2]
		p.year = pin[2..4]
		p.month = pin[4..6]
		p.day = pin[6..8]
		p.num = pin[8..11]
		p.check = pin[11..12]
	} else if pin.len == 10 {
		p.year = pin[0..2]
		p.month = pin[2..4]
		p.day = pin[4..6]
		p.num = pin[6..9]
		p.check = pin[9..10]
	} else {
		return personnummer.err_invalid_number
	}

	if p.num == '000' {
		return personnummer.err_invalid_number
	}

	p.sep = '-'

	now := time.now()

	if p.century.len == 0 {
		mut base_year := now.year

		if plus {
			p.sep = '+'
			base_year -= 100
		}

		p.century = (base_year - (base_year - p.year.int()) % 100).str()[0..2]
	} else {
		if now.year - (p.century + p.year).int() < 100 {
			p.sep = '-'
		} else {
			p.sep = '+'
		}
	}

	p.full_year = p.century + p.year

	return true
}

// valid validates a Swedish personal identity number.
pub fn (p Personnummer) valid() bool {
	valid := luhn(p.year + p.month + p.day + p.num) == p.check.int()

	if valid && validate_date(p.full_year, p.month, p.day) {
		return true
	}

	return valid && p.is_coordination_number()
}
