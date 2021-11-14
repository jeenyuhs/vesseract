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

fn test_string_extraction_dan() {
	text := extract_string(image: 'sample/snippet_dan.png', lang: 'dan', conf: '--oem 1 --psm 3') or {
		panic(err)
	}
	line := text.split('\n').filter(it != '')

	assert line[1] == 'Jeg sad i havestuen i Georgia Pines med min fars fyldepen'
	assert line[4].contains('Den Grønne Mil')
}
