module personnummer

import time
import math

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

	 return int(math.pow(math.ceil(math.round(sum)/10)*10 - sum, 1.0))
}

fn test_date(year string, month string , day string ) bool {
	//  y := year.int()
	//  m := month.int()
	//  dd := day.int()
	//  d := DateTime(y, m, dd);
	// return d.year == y && d.month == m && d.day == dd;
	return true
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
	leap_year           bool
	coordination_number bool
}

// // Options represents the personnummer options.
// struct Options {
// }


// parse Swedish personal identity numbers and set struct properpties or return a error.
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

pub fn (p Personnummer) valid() bool {
	 valid := luhn(p.year + p.month + p.day + p.num) == p.check.int()

	 if valid && test_date(p.full_year, p.month, p.day) {
		 return true
	 }

	 // TODO:
	 // - isCoordinationNumber

		// try
		// {
		// 	if (valid && testDate(this.fullYear, this.month, this.day))
		// 	{
		// 		return true;
		// 	}
		// }
		// catch (Throwable)
		// {
		// 	return valid && this.isCoordinationNumber();
		// }

		// return false;

	return false
}

// New parse a Swedish personal identity numbers and returns a new struct or a error.
pub fn new(pin string) ?Personnummer {
	mut p := Personnummer{}

	output := p.parse(pin) or {
		return error('parse error')
	}

	if output {
		p.valid()
		return p
	}

	return error('new error')
}