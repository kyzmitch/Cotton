SHELL := /bin/bash -o pipefail
# Use -p to prevent the error if the directory exists
MKDIR_P = mkdir -p

RUBY_USER_DIR := $(shell ruby -r rubygems -e 'puts Gem.user_dir')
XCPRETTY := bundle exec xcpretty
# Define swiftlint
SWIFTLINT = swiftlint lint catowseriOS --config catowseriOS/.swiftlint.yml --quiet
# Domain package is iOS-only; match a simulator available on macos-26 / Xcode 26.x runners.
# Override locally if needed: make github-ios-unit-tests IOS_SIM_DESTINATION='platform=iOS Simulator,name=iPhone 16'
IOS_SIM_DESTINATION ?= platform=iOS Simulator,name=iPhone 17

ifeq ($(RUBY_USER_DIR),)
$(error Unable to find ruby user install directory)
endif

# GRADLE = /usr/local/opt/gradle@7/bin/gradle
# $(call GRADLE, wrapper);

# bash profile update every time is not a good option
# `echo 'export PATH="/usr/local/opt/gradle@7/bin:$PATH"' >> ~/.bash_profile ;`

# specific Maven publish doesn't work and have to use `publishToMavenLocal`
# `./gradlew publishAndroidDebugPublicationToMavenLocal;`

# Following command shows currently installed SDKs on the system
# use `-sdk macosx13.1` for specific on CI and `-sdk macosx` means the latest for local
# `xcodebuild -showsdks`

# Github workflow builds

.PHONY: github-workflow-ios
github-workflow-ios: build-cotton-base-ios-release
	cd catowseriOS; \
	xcodebuild -scheme "Cotton dev" build \
	-workspace catowser.xcworkspace \
	-quiet \
	-configuration "Release" \
	-sdk iphonesimulator \
	-arch x86_64 \
	-clonedSourcePackagesDirPath SourcePackages; \
	cd ..; \

.PHONY: github-workflow-android
github-workflow-android: build-cotton-base-android-release
	cd catowserAndroid; \
	echo "sdk.dir=${HOME}/Library/Android/sdk" > local.properties; \
	./gradlew ktlintCheck; \
	./gradlew app:build; \
	cd ..; \

# Local builds

.PHONY: build-ios-dev-release
build-ios-dev-release: build-cotton-base-ios-release ios-lint
	cd catowseriOS; \
	xcodebuild -scheme "Cotton dev" build \
	 -workspace catowser.xcworkspace \
	 -quiet \
	 -configuration "Release" \
	 -sdk iphonesimulator \
	 -arch x86_64; \
	 cd ..; \

.PHONY: build-android-dev-release
build-android-dev-release: build-cotton-base-android-release android-lint
	cd catowserAndroid; \
	echo "sdk.dir=${HOME}/Library/Android/sdk" > local.properties; \
	./gradlew ktlintCheck; \
	./gradlew app:build; \
	cd ..; \

# Setup

.PHONY: setup
setup:
	$(DISPLAY_SEPARATOR)
	gem install bundler:2.1.4 --user-install
	$(DISPLAY_SEPARATOR)
	bundle config set path 'vendor/bundle'
	bundle install
	$(DISPLAY_SEPARATOR)
	brew update
	$(DISPLAY_SEPARATOR)
	brew untap cotton-user/cotton-brew-taps
	$(DISPLAY_SEPARATOR)
	brew tap-new cotton-user/cotton-brew-taps
	$(DISPLAY_SEPARATOR)
	$(MKDIR_P) /opt/homebrew/Library/Taps/cotton-user/homebrew-cotton-brew-taps/Formula
	$(DISPLAY_SEPARATOR)
	cp ./brew_configs/* /opt/homebrew/Library/Taps/cotton-user/homebrew-cotton-brew-taps/Formula
	$(DISPLAY_SEPARATOR)
	brew bundle install --file=/opt/homebrew/Library/Taps/cotton-user/homebrew-cotton-brew-taps/Formula/Brewfile
	$(DISPLAY_SEPARATOR)
	xcode-kotlin sync

.PHONY: clean
clean:
	cd cotton-base; rm -rf build; cd ..; \
	cd catowseriOS; \
	rm -rf Build; \
	rm -rf DerivedData; \
	rm -rf SourcePackages; \
	cd ..; \
	cd catowserAndroid; rm -rf build; cd ..; \

# Linters

.PHONY: ios-lint
ios-lint:
	swiftlint --version; \
$(SWIFTLINT) 2>&1 | grep "error:" || echo "SwiftLint: Errors not found." \
	
.PHONY: ios-lint-format
ios-lint-format:
	swiftlint --version; \
swiftlint lint catowseriOS --config catowseriOS/.swiftlint.yml --quiet --autocorrect --format; \

.PHONY: android-lint
android-lint:
	ktlint catowserAndroid/**/*.kt --editorconfig=catowserAndroid/.editorconfig ; \
	# --disabled_rules=trailing-comma,standard:trailing-comma-on-call-site,
	# standard:trailing-comma-on-declaration-site,standard:colon-spacing,standard:no-wildcard-imports,
	# final-newline,standard:trailing-comma-on-call-site

.PHONY: android-kotlin-format
android-kotlin-format:
	ktlint catowserAndroid/**/*.kt --format ;

# Cotton base builds

.PHONY: lint-kt-cotton-base
lint-kt-cotton-base:
	ktlint cotton-base/**/*.kt --editorconfig=cotton-base/.editorconfig ; \
	# --disabled_rules=trailing-comma,standard:trailing-comma-on-call-site,
	# standard:trailing-comma-on-declaration-site,standard:colon-spacing,standard:no-wildcard-imports,
	# final-newline,standard:trailing-comma-on-call-site

.PHONY: lint-kt-cotton-base-format
lint-kt-cotton-base-format:
	ktlint --format cotton-base/**/*.kt --editorconfig=cotton-base/.editorconfig ; \
	# --disabled_rules=trailing-comma,standard:trailing-comma-on-call-site,
	# standard:trailing-comma-on-declaration-site,standard:colon-spacing,standard:no-wildcard-imports,
	# final-newline,standard:trailing-comma-on-call-site

.PHONY: build-cotton-base-ios-release
build-cotton-base-ios-release:
	cd cotton-base; \
	if [ -f "$(HOME)/.zprofile" ]; then source "$(HOME)/.zprofile"; fi; \
	echo "sdk.dir=~/Library/Android/sdk" > local.properties; \
	export ANDROID_HOME=~/Library/Android/sdk; \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	cd ..; \

.PHONY: build-cotton-base-android-release
build-cotton-base-android-release:
	cd cotton-base; \
	echo "sdk.dir=~/Library/Android/sdk" > local.properties; \
	export ANDROID_HOME=~/Library/Android/sdk; \
	./gradlew publishToMavenLocal; \
	cd ..; \

.PHONY: build-cotton-base-release
build-cotton-base-release: build-cotton-base-ios-release build-cotton-base-android-release

# Local unit tests

.PHONY: ios-unit-tests
ios-unit-tests: build-cotton-base-ios-release
	cd catowseriOS; \
	xcodebuild -scheme "Cotton" test \
	 -workspace catowser.xcworkspace \
	 -testPlan TestPlan \
	 -destination '$(IOS_SIM_DESTINATION)' \
	 -run-tests-until-failure \
	 CODE_SIGNING_ALLOWED=NO \
	 | $(XCPRETTY) --test; \
	cd ..; \

# Github workflow unit tests (specific macOS runners)
# Uses Cotton scheme + catowser/TestPlan.xctestplan (SPM test targets in Domain/Base).

.PHONY: github-ios-unit-tests
github-ios-unit-tests: build-cotton-base-ios-release
	cd catowseriOS; \
	xcodebuild -scheme "Cotton" test \
	 -workspace catowser.xcworkspace \
	 -testPlan TestPlan \
	 -destination '$(IOS_SIM_DESTINATION)' \
	 -run-tests-until-failure \
	 -clonedSourcePackagesDirPath SourcePackages \
	 CODE_SIGNING_ALLOWED=NO \
	 | $(XCPRETTY) --test; \
	cd ..; \

# Help

define HELP_CONTENT
Local and CI targets
\tUniversal targets
\t\t* make setup\t\t: Downloads local dependencies like SwiftLint, KtLint, Gradle for command line, etc.
\t\t* make clean\t\t: Cleans all build artifacts for both platforms.

\tiOS build
\t\t* make build-ios-dev-release\t: Build Release version of Kotlin multiplatform & Xcode project.
\t\t* make github-workflow-ios\t: GitHub workflow for iOS.
\t\t* make ios-lint\t\t\t: Only run linter on Swift files.

\tAndroid build
\t\t* make build-android-dev-release: Build Release version of Kotlin multiplatform & Android project.
\t\t* make github-workflow-android\t: GitHub workflow for Android.
\t\t* make android-lint\t\t: CLI kotlin lint.

\tCotton-Base build
\t\t* make build-cotton-base-ios-release\t\t: Build cotton-base XCFramework for iOS.
\t\t* make build-cotton-base-android-release\t: Build & publish cotton-base to local Maven for Android.
\t\t* make build-cotton-base-release\t\t: Build cotton-base together for iOS & Android.
\t\t* make lint-kt-cotton-base\t\t\t: Lint Kotlin in cotton-base.
\t\t* make lint-kt-cotton-base-format\t\t: Auto-correct Kotlin in cotton-base.

\tUnit tests
\t\t* make ios-unit-tests\t\t\t: Build and run iOS unit tests.
endef

export HELP_CONTENT

.PHONY: help
help:
	@printf "$$HELP_CONTENT\n"
