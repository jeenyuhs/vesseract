module vesseract

import os

const (
	supported = ['PNG', 'JPEG']
)

pub struct Tesseract {
pub:
	// Image path
	image string
	// Custom arguments
	args string
	// Set language
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
		return error("vesseract: error $s.exit_code \"$s.output\"")
	}

	return s.output
}

fn extract_text_tesseract(t Tesseract) ? {
	if !os.exists(t.image) {
		return error('vesseract: Image not found.')
	}

	// Arguments
	mut args := []string{}

	// Add image path
	args << t.image

	// Output tmp
	args << t.output

	if t.lang.len > 0 {
		args << '-l ' + t.lang
	}

	// Add more args if required
	if t.args.len > 0 {
		args << t.args
	}

	// Run tesseract with custom arguments
	run_tesseract(args) or { return err }
}

// Extract text from image
pub fn image_to_string(t Tesseract) ?string {
	// Run tesseract
	extract_text_tesseract(t) or { return err }

	// Tmp txt file output
	path := t.output + '.txt'

	// Read output
	str := os.read_file(path) or { return err }

	// Remove tmp txt file
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

// Get alto representation from Tesseract-OCR as XML format
pub fn image_to_alto_xml(image string) ?string {
	// Tesseract option: -c tessedit_create_alto=1

	// Check version for alto support
	ver := get_tesseract_version() or { return err }

	if ver.major <= 4 && ver.minor < 1 {
		return error('vesseract: Alto export require Tesseract >= 4.1.0')
	}

	// Run tesseract
	run_tesseract([image, 'out', '-c tessedit_create_alto=1']) or { return err }

	// Read output
	xml := os.read_file('out.xml') or { return err }

	// Delete
	os.rm('out.xml') ?

	// Get XML
	return xml
}
