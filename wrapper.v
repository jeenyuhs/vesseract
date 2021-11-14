module vesseract

import os

// Run Tesseract-OCR with arguments
fn run_tesseract(arguments []string) ?string {
	mut s := os.execute('tesseract ' + arguments.join(' '))

	if s.exit_code != 0 {
		return error("vesseract: error $s.exit_code \"$s.output\"")
	}

	return s.output
}

// Run commands from struct
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
