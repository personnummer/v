module test

import personnummer

fn test_personnummer() {
	assert personnummer.valid('197306749982') == true
}