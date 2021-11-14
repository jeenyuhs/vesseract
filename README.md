# Vesseract

A V wrapper for Tesseract-OCR inspired by pytesseract!

Install the package from VPM:
```
v install barrack-obama.vesseract
```
# Quickstart

```v
import vesseract

// Extract text from image
text := vesseract.image_to_string(
        image: 'sample/demo.png', lang: 'eng', args: '') or {
		panic(err)
}
// Got: Hi from Vesseract !
println("Got: $text")

// Get tesseract version
version := vesseract.get_tesseract_version()
// 4.1.0 installed: "Tesseract 4 - 1 - 0 detected!
println("Tesseract $version.major - $version.minor - $version.patch detected!")

// Get languages supported by Tesseract
langs := vesseract.get_languages()
// Example: ['afr', 'amh', 'ara', 'asm', ... 'uzb_cyrl', 'vie', 'yid', 'yor']

// Get alto xml
alto := vesseract.image_to_alto_xml()
// "XML: <?xml version="1.0" encoding="UTF-8"?> ... "
println("XML: $alto")
```
# Contributors

* Simon "Barrack Obama"
* SheatNoisette
# License

This wrapper is licensed under the MIT License, see ```LICENSE``` for details