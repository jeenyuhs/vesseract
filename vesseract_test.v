module vesseract

// Used for tests
fn tr_find(list []string, item string) bool {
	for e in list {
		if e == item {
			return true
		}
	}
	return false
}

fn test_get_languages() {
	langs := get_languages() or { panic(err) }

	assert tr_find(langs, 'fra')
	assert tr_find(langs, 'dan')
	assert tr_find(langs, 'UNKNOWNLANG') == false
}

fn test_get_tesseract_version() {
	ver := get_tesseract_version() or { panic(err) }

	// Version 4 of tesseract as a baseline
	assert ver.major == 4
	assert ver.minor > 0
	assert ver.patch > 0
}

fn test_image_to_string_dan() {
	text := image_to_string(image: 'sample/snippet_dan.png', lang: 'dan', args: '--oem 1 --psm 3') or {
		panic(err)
	}
	line := text.split('\n').filter(it != '')

	assert line[1] == 'Jeg sad i havestuen i Georgia Pines med min fars fyldepen'
	assert line[4].contains('Den Grønne Mil')
}

fn test_image_to_string_demo() {
	text := image_to_string(image: 'sample/demo.png', lang: 'eng', args: '') or { panic(err) }

	assert text == 'Hi from Vesseract !'
}

fn test_image_to_string_empty() {
	text := image_to_string(image: 'sample/empty.png', lang: 'eng', args: '') or { panic(err) }

	assert text == ''
}

fn test_image_to_alto_xml() {
	xml := image_to_alto_xml(image: 'sample/demo.png', lang: 'eng', args: '') or { panic(err) }
	assert xml.contains('http://www.loc.gov/standards/alto/ns-v3#')
}

fn test_image_to_alto_xml_path() {
	xml := image_to_alto_xml_path('sample/demo.png') or { panic(err) }
	assert xml.contains('http://www.loc.gov/standards/alto/ns-v3#')
}

fn test_image_to_boxes() {
	boxes := image_to_boxes(image: 'sample/demo.png', lang: 'eng', args: '') or { panic(err) }

	assert boxes[0].x1 == 68
	assert boxes[0].y1 == 206
	assert boxes[0].x2 == 91
	assert boxes[0].y2 == 235
	assert boxes.len == 16
}

fn test_image_to_boxes_empty() {
	boxes := image_to_boxes(image: 'sample/empty.png', lang: 'eng', args: '') or { panic(err) }

	assert boxes.len == 0
}
