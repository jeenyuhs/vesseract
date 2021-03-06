module vesseract

import os
import rand
import time

// Tesseract output struct
struct Tesseract_output {
pub:
	// Path of the image
	image_path string
	// Arguments given to tesseract
	arguments []string
	// File generated by tesseract
	output_filename string
	// Tesseract output stdout
	stdout_result string
	// ID generated
	id string
}

// Generate a id for a document to be processed
// This avoid congestion if Tesseract is ran in parallel
fn generate_id() string {
	mut str := ''

	unix_time := time.now().unix_time().str()
	rand := rand.byte().str()

	str += unix_time
	str += rand

	return str
}

// Run Tesseract-OCR with arguments
fn run_tesseract(arguments []string) ?string {
	mut s := os.execute('tesseract ' + arguments.join(' '))

	if s.exit_code != 0 {
		return error("vesseract: error $s.exit_code \"$s.output\"")
	}

	return s.output
}

// Run commands from struct
fn extract_text_tesseract(t Tesseract) ?Tesseract_output {
	if !os.exists(t.image) {
		return error('vesseract: Image not found.')
	}

	// Arguments
	mut args := []string{}

	// Add image path
	args << t.image

	// Output tmp - Random ID
	doc_id := generate_id()
	// Output file (tesseract append .txt)
	args << doc_id

	if t.lang.len > 0 {
		args << '-l ' + t.lang
	}

	// Add more args if required
	if t.args.len > 0 {
		args << t.args
	}

	// Run tesseract with custom arguments
	stdout := run_tesseract(args) or { return err }

	return Tesseract_output{
		image_path: t.image
		arguments: args
		output_filename: doc_id + '.txt'
		stdout_result: stdout
		id: doc_id
	}
}
