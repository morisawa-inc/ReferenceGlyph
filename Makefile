.PHONY: plugin
plugin:
	xcodebuild
	cp -r build/Release/*.glyphsPalette .

.PHONY: clean
clean:
	rm -rf build
	rm -rf *.glyphsPalette

archive: clean plugin
	CURRENT_DIR=$$(pwd); \
	PROJECT_NAME=$$(basename "$${CURRENT_DIR}"); \
	git archive -o "build/Release/$${PROJECT_NAME}-$$(git rev-parse --short HEAD).zip" HEAD

dist: clean plugin archive
