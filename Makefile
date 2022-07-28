CURRENT_DIR  := $(shell pwd)
PROJECT_NAME := $(shell basename "$(CURRENT_DIR)")

.PHONY: plugin
plugin:
	xcodebuild -target $(PROJECT_NAME)3
	command -v postbuild-codesign >/dev/null 2>&1 && postbuild-codesign
	command -v postbuild-notarize >/dev/null 2>&1 && postbuild-notarize
	cp -r build/Release/*.glyphsPalette .

.PHONY: clean
clean:
	rm -rf build
	rm -rf *.glyphsPalette

archive: clean plugin
	git archive -o "build/Release/$(PROJECT_NAME)-$$(git rev-parse --short HEAD).zip" HEAD

dist: clean plugin archive
