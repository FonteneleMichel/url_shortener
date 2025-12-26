.PHONY: pub format analyze test check

pub:
	flutter pub get

format:
	dart format .

analyze:
	flutter analyze --no-pub

test:
	flutter test --no-pub

check: pub format analyze test
