.PHONY: check check-ci format analyze test test-ci

check: format analyze test

check-ci: format analyze test-ci

format:
	dart format .

analyze:
	flutter analyze --no-pub

test:
	flutter test --no-pub --exclude-tags golden

test-ci:
	flutter test --no-pub
