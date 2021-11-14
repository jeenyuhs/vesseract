module vesseract

import os

const (
	supported = ['PNG', 'JPEG']
)

pub struct Tesseract {
pub:
	image  string
	conf   string
	lang   string
	output string = 'txt'
}

fn run_and_get_output(t Tesseract) ?os.Result {
	if !os.exists(t.image) {
		return error('vesseract: Image not found.')
	}

	mut args := []string{}

	args << t.image
	args << t.output

	if t.lang.len > 0 {
		args << '-l ' + t.lang
	}

	if t.conf.len > 0 {
		args << t.conf
	}
	mut s := os.execute('tesseract ' + args.join(' '))

	if s.exit_code != 0 {
		return error("vesseract - error $s.exit_code \"$s.output\"")
	}

	unsafe { s.free() }

	return s
}

pub fn extract_string(t Tesseract) ?string {
	run_and_get_output(t) or { return err }
	path := t.output + '.txt'

	str := os.read_file(path) or { return err }

	os.rm(path) ?

	return str[..str.len - 2]
}
