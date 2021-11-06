module vesseract

fn test_string_extraction() {
	text := extract_string(image: "sample/snippet_dan.png", lang: "dan", conf: "--oem 1 --psm 3") or { 
		panic(err)
	}
	line := text.split("\n").filter(it != "")

	assert line[1] == "Jeg sad i havestuen i Georgia Pines med min fars fyldepen"
	assert line[4].contains("Den Grønne Mil")
}
