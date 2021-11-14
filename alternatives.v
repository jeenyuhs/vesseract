module vesseract

// Variant of image_to_alto_xml() but don't need extra parameters
[inline]
pub fn image_to_alto_xml_path(image_path string) ?string {
	return image_to_alto_xml(image: image_path, lang: 'eng', args: '')
}

// Variant of image_to_string, only a file path is required
[inline]
pub fn image_to_string_path(filepath string) ?string {
	return image_to_string(image: filepath, lang: 'eng', args: '')
}