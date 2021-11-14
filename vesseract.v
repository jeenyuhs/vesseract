module vesseract

import os

pub struct Tesseract {
pub:
	// Image path
	image string
	// Custom arguments
	args string
	// Set language
	lang string = 'eng'
}

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

// Variant of image_to_string, only a file path is required
pub fn image_to_string_path(filepath string) ?string {
	return image_to_string(image: filepath, lang: 'eng', args: '')
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
pub fn image_to_alto_xml(image string) ?string {
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
	run_tesseract([image, id, '-c tessedit_create_alto=1']) or { return err }

	// Read output
	xml := os.read_file(xml_filename) or { return err }

	// Delete
	os.rm(xml_filename) ?

	// Get XML
	return xml
}
