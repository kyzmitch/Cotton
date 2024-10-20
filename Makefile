SHELL := /bin/bash -o pipefail

RUBY_USER_DIR := $(shell ruby -r rubygems -e 'puts Gem.user_dir')
XCPRETTY := bundle exec xcpretty
SWIFTYMOCKY := ${HOME}/.mint/bin/swiftymocky
# For 15.0.1 need to use next SDK
# Have to use Beta macos-13 runner, because only there is Xcode 15
# https://github.com/actions/runner-images/blob/main/images/macos/macos-13-Readme.md
MACOSSDK_VERSION := macosx14.0

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
	brew bundle install --file=./brew_configs/Brewfile
	$(DISPLAY_SEPARATOR)
	mint install MakeAWishFoundation/SwiftyMocky
	export PATH="${PATH}:${HOME}/.mint/bin"
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
	swiftlint lint catowseriOS --config catowseriOS/.swiftlint.yml --quiet; \
	
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

.PHONY: build-cotton-base-ios-release
build-cotton-base-ios-release:
	cd cotton-base; \
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

.PHONY: ios-tests-core-browser
ios-tests-core-browser: build-cotton-base-ios-release
	cd catowseriOS; \
	xcodebuild -scheme "CoreBrowser Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk macosx | $(XCPRETTY) --test \
	 cd ..; \

.PHONY: ios-tests-cotton-data
ios-tests-cotton-data: build-cotton-base-ios-release
	cd catowseriOS; \
	$(SWIFTYMOCKY) doctor ; \
    $(SWIFTYMOCKY) generate ; \
	xcodebuild -scheme "CottonData Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk macosx | $(XCPRETTY) --test \
	 cd ..; \

.PHONY: ios-unit-tests
ios-unit-tests: build-cotton-base-ios-release
	cd catowseriOS; \
	xcodebuild -scheme "CoreBrowser Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk macosx | $(XCPRETTY) --test; \
	xcodebuild -scheme "CottonRestKit Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk macosx | $(XCPRETTY) --test; \
	xcodebuild -scheme "CottonPlugins Unit tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk macosx | $(XCPRETTY) --test; \
	cd ..; \

# $(SWIFTYMOCKY) doctor ; \
# $(SWIFTYMOCKY) generate ; \
# xcodebuild -scheme "CottonData Unit Tests" test \
# -workspace catowser.xcworkspace \
# -run-tests-until-failure \
# -destination platform=macOS, arch=x86_64 \
# -sdk macosx | $(XCPRETTY) --test; \

# Github workflow unit tests (specific macOS runners)

.PHONY: github-ios-unit-tests
github-ios-unit-tests: build-cotton-base-ios-release
	brew bundle install --file=./brew_configs/Brewfile; \
	export PATH="${PATH}:${HOME}/.mint/bin" ; \
	@echo "mint install MakeAWishFoundation/SwiftyMocky;" ; \
	sourcery --config "catowseriOS/CoreBrowserTests/.sourcery.yml"
	cd catowseriOS; \
	xcodebuild -scheme "CoreBrowser Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk $(MACOSSDK_VERSION) | $(XCPRETTY) --test && exit ${PIPESTATUS[0]}; \
	xcodebuild -scheme "CottonRestKit Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk $(MACOSSDK_VERSION) | $(XCPRETTY) --test && exit ${PIPESTATUS[0]}; \
	xcodebuild -scheme "CottonPlugins Unit tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -sdk $(MACOSSDK_VERSION) | $(XCPRETTY) --test && exit ${PIPESTATUS[0]}; \
	 xcodebuild -scheme "CottonData Unit Tests" test \
	 -workspace catowser.xcworkspace \
	 -run-tests-until-failure \
	 -destination platform=macOS, arch=x86_64 \
	 -sdk $(MACOSSDK_VERSION) | $(XCPRETTY) --test && exit ${PIPESTATUS[0]}; \
	cd ..; \
	cd catowseriOS; \
	 cd ..; \

# mint install MakeAWishFoundation/SwiftyMocky; \
# swiftymocky doctor ; \
# swiftymocky generate ; \
# xcodebuild -scheme "CottonData Unit Tests" test \
# -workspace catowser.xcworkspace \
# -run-tests-until-failure \
# -destination platform=macOS, arch=x86_64 \
# -sdk $(MACOSSDK_VERSION) | $(XCPRETTY) --test; \

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

\tUnit tests
\t\t* make ios-unit-tests\t\t\t: Build and run iOS unit tests.
\t\t* make ios-tests-core-browser\t\t: Build and run Cotton-base Kotlin unit tests.
\t\t* make ios-tests-cotton-data\t\t: run Swiftymocky based tests
endef

export HELP_CONTENT

.PHONY: help
help:
	@printf "$$HELP_CONTENT\n"
