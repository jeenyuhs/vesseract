module vesseract

import os

// Used for bounding box detection
pub struct Tesseract_box {
pub:
	letter string
	x1     u32
	y1     u32
	x2     u32
	y2     u32
	page   u32
}

// Used as a parameter
pub struct Tesseract {
pub:
	// Image path
	image string
	// Custom arguments
	args string
	// Set language
	lang string = 'eng'
}

// Used to make it easier to get tesseract version
pub struct Tesseract_version {
pub:
	major int
	minor int
	patch int
	str   string = '0.0.0'
	raw   string = 'tesseract'
}

// Extract text from image
pub fn image_to_string(t Tesseract) ?string {
	// Run tesseract
	result := extract_text_tesseract(t) or { return err }

	// Tmp txt file output
	file_path := result.output_filename

	// Read output
	str := os.read_file(file_path) or { return err }

	// Remove tmp txt file
	os.rm(file_path) ?

	// Check if tesseract find something
	if str.len <= 1 {
		return ''
	}

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

	// Extract major/minor/patch
	t_version_major := int(t_version_num[0].u32())
	t_version_minor := int(t_version_num[1].u32())
	t_version_patch := int(t_version_num[2].u32())

	// Set values into struct
	return Tesseract_version{
		major: t_version_major
		minor: t_version_minor
		patch: t_version_patch
		str: t_version_str
		raw: t_version_raw
	}
}

// Get alto representation from Tesseract-OCR as XML format
pub fn image_to_alto_xml(t Tesseract) ?string {
	// Tesseract option: -c tessedit_create_alto=1

	// Check version for alto support
	ver := get_tesseract_version() or { return err }

	if ver.major <= 4 && ver.minor < 1 {
		return error('vesseract: Alto export require Tesseract >= 4.1.0')
	}

	// Generate result id
	id := generate_id()
	xml_filename := id + '.xml'

	// Run tesseract
	run_tesseract([t.image, id, '-c tessedit_create_alto=1', t.args]) or { return err }

	// Read output
	xml := os.read_file(xml_filename) or { return err }

	// Delete
	os.rm(xml_filename) ?

	// Get XML
	return xml
}

// Get bounding boxes from Tesseract
// Return an array of Tesseract boxes
pub fn image_to_boxes(t Tesseract) ?[]Tesseract_box {
	// Run tesseract with bounding box detection
	result := extract_text_tesseract(
		image: t.image
		lang: t.lang
		args: t.args + ' batch.nochop makebox'
	) or { return err }

	// Load box file
	box_file := os.read_file(result.id + '.box') or { return err }
	lines := box_file.split('\n')

	// Delete "box" file and txt
	os.rm(result.id + '.box') ?

	// Hold results
	mut boxes := []Tesseract_box{}

	// Parse
	for line in lines {
		// Letter, x1, y1, x2, y1, page
		// Example: H 68 206 91 235 0
		content := line.split(' ')

		// Skip malformed lines
		if content.len != 6 {
			continue
		}

		boxes << Tesseract_box{
			letter: content[0]
			x1: content[1].u32()
			y1: content[2].u32()
			x2: content[3].u32()
			y2: content[4].u32()
			page: content[5].u32()
		}
	}

	return boxes
}
