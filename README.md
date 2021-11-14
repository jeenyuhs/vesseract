# Vesseract

A "WIP" V wrapper for Tesseract-OCR inspired by pytesseract wrapper!

Tesseract OCR is a optical character recognition software made by Google,
it can "read" text from an image.

First install Tesseract and check if it is registered in your path.

Install the package from VPM:
```
v install barrack-obama.vesseract
```
# Quickstart

```v
import barrack-obama.vesseract

// Extract text from image
// Image: path - lang: Language for tesseract - args: custom arguments
text := vesseract.image_to_string(
        image: 'sample/demo.png', lang: 'eng', args: '') or {
		panic(err)
}
// Or simply: vesseract.image_to_string_path('sample/demo.png')
// "Got: Hi from Vesseract !"
println("Got: $text")

// Get Tesseract version
version := vesseract.get_tesseract_version() or { panic(err) }
// 4.1.0 installed: "Tesseract 4 - 1 - 0 detected!"
println("Tesseract $version.major - $version.minor - $version.patch detected!")

// Get languages supported by Tesseract
langs := vesseract.get_languages() or { panic(err) }
// Example: "['afr', 'amh', 'ara', 'asm', ... 'uzb_cyrl', 'vie', 'yid', 'yor']"
println("$langs")

// Get alto xml - Require Tesseract >4.1.0
alto := vesseract.image_to_alto_xml('sample/demo.png') or { panic(err) }
// "XML: <?xml version="1.0" encoding="UTF-8"?> ... "
println("XML: $alto")
```
# License

This wrapper is licensed under the MIT License, see ```LICENSE``` for details