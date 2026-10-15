.PHONY: tokens check-tokens test-compose test-flutter analyze apk-compose apk-flutter

tokens:
	npm ci --prefix tools/tokens
	npm --prefix tools/tokens run sync
	npm --prefix tools/tokens run icons
	python3 tools/generate_tokens.py
	python3 tools/generate_icons.py

check-tokens:
	npm --prefix tools/tokens run check
	python3 tools/generate_tokens.py --check
	python3 tools/generate_icons.py --check

test-compose:
	@if [ -z "$$DISPLAY" ] && command -v xvfb-run >/dev/null 2>&1; then xvfb-run -a ./gradlew :fluent-compose:desktopTest; else ./gradlew :fluent-compose:desktopTest; fi

test-flutter:
	cd packages/flutter && flutter pub get && flutter test
	cd examples/flutter && flutter pub get && flutter test

analyze:
	cd packages/flutter && flutter analyze
	cd examples/flutter && flutter analyze

apk-compose:
	./gradlew :compose-catalog:assembleDebug

apk-flutter:
	cd examples/flutter && flutter build apk --release --split-per-abi --target-platform android-arm64,android-x64
