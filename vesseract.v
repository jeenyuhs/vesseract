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

pub struct Tesseract_version {
pub:
	major int
	minor int
	patch int
	str   string = '0.0.0'
	raw   string = 'tesseract'
}

// Run Tesseract-OCR with arguments
fn run_tesseract(arguments []string) ?string {
	mut s := os.execute('tesseract ' + arguments.join(' '))

	if s.exit_code != 0 {
		return error("vesseract - error $s.exit_code \"$s.output\"")
	}

	return s.output
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

	return s
}

pub fn extract_string(t Tesseract) ?string {
	run_and_get_output(t) or { return err }
	path := t.output + '.txt'

	str := os.read_file(path) or { return err }

	os.rm(path) ?

	return str[..str.len - 2]
}

// Get installed languages from Tesseract-OCR
// return a list of languages code
pub fn get_languages() ?[]string {
	// Language list
	mut langs_supported := []string{}

	// Get tesseract langs
	t_result := run_tesseract(['--list-langs']) or { return err }

	// Split
	content := t_result.split('\n')

	// Skip first line
	for i in 1 .. content.len {
		line := content[i]

		// Filter empty lines
		if line.len > 0 {
			langs_supported << content[i]
		}
	}

	return langs_supported
}

// Get tesseract-OCR version
pub fn get_tesseract_version() ?Tesseract_version {
	// Get tesseract version
	t_result := run_tesseract(['--version']) or { return err }

	// Get tesseract string
	lines := t_result.split('\n')
	t_version_raw := lines[0].trim('\r')

	// Extract version string - ex: 4.1.1
	t_version_str := t_version_raw.split(' ')[1]

	// Get version numbers
	t_version_num := t_version_str.split('.')

	// Extract major/medium/minor
	t_version_major := int(t_version_num[0].u32())
	t_version_minor := int(t_version_num[1].u32())
	t_version_patch := int(t_version_num[2].u32())

	// Set values into struct
	mut version_struct := Tesseract_version{
		major: t_version_major
		minor: t_version_minor
		patch: t_version_patch
		str: t_version_str
		raw: t_version_raw
	}

	return version_struct
}
