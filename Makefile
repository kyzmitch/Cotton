SHELL := /bin/bash -o pipefail

RUBY_USER_DIR := $(shell ruby -r rubygems -e 'puts Gem.user_dir')

ifeq ($(RUBY_USER_DIR),)
$(error Unable to find ruby user install directory)
endif

# GRADLE = /usr/local/opt/gradle@7/bin/gradle
# $(call GRADLE, wrapper);

# bash profile update every time is not a good option
# echo 'export PATH="/usr/local/opt/gradle@7/bin:$PATH"' >> ~/.bash_profile ;

# specific Maven publish doesn't work and have to use `publishToMavenLocal`
# ./gradlew publishAndroidDebugPublicationToMavenLocal; 

.PHONY: github-workflow-ios
github-workflow-ios:
	cd cotton-base; \
	./gradlew ktlintCheck; \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	cd ..; \
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
github-workflow-android:
	cd cotton-base; \
	echo "sdk.dir=${HOME}/Library/Android/sdk" > local.properties; \
	export ANDROID_HOME=${HOME}/Library/Android/sdk; \
	./gradlew ktlintCheck; \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	./gradlew publishToMavenLocal; \
	cd ..; \
	cd catowserAndroid; \
	echo "sdk.dir=${HOME}/Library/Android/sdk" > local.properties; \
	./gradlew ktlintCheck; \
	./gradlew app:build; \
	cd ..; \

.PHONY: setup
setup:
	gem install bundler -v '~> 1.0' --user-install
	$(DISPLAY_SEPARATOR)
	brew update
	$(DISPLAY_SEPARATOR)
	brew bundle install --file=./brew_configs/Brewfile
	mint install MakeAWishFoundation/SwiftyMocky

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
build-android-dev-release: build-cotton-base-android-release
	cd catowserAndroid; \
	echo "sdk.dir=${HOME}/Library/Android/sdk" > local.properties; \
	./gradlew ktlintCheck; \
	./gradlew app:build; \
	cd ..; \

.PHONY: clean
clean:
	cd cotton-base; rm -rf build; cd ..; \
	cd catowseriOS; \
	rm -rf Build; \
	rm -rf DerivedData; \
	rm -rf SourcePackages; \
	cd ..; \
	cd catowserAndroid; rm -rf build; cd ..; \

.PHONY: ios-lint
ios-lint:
	swiftlint --version; \
	swiftlint lint catowseriOS --config catowseriOS/.swiftlint.yml --quiet; \

.PHONY: android-lint
android-lint:
	ktlint catowserAndroid/**/*.kt --editorconfig=catowserAndroid/.editorconfig ; \
	# --disabled_rules=trailing-comma,standard:trailing-comma-on-call-site,
	# standard:trailing-comma-on-declaration-site,standard:colon-spacing,standard:no-wildcard-imports

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

define HELP_CONTENT
Local and CI targets
\tUniversal targets
\t\t* make setup\t\t: Downloads local dependencies like SwiftLint, KtLint, Gradle for command line, etc.
\t\t* make clean\t\t: Cleans all build artifacts for both platforms.

\tiOS build
\t\t* make build-ios-dev-release\t\t: Build Release version of Kotlin multiplatform & Xcode project.
\t\t* make github-workflow-ios\t\t: GitHub workflow for iOS.
\t\t* make ios-lint\t\t: Only run linter on Swift files.

\tAndroid build
\t\t* make build-android-dev-release\t\t: Build Release version of Kotlin multiplatform & Android project.
\t\t* make github-workflow-android\t\t: GitHub workflow for Android.
\t\t* make android-lint\t\t: CLI kotlin lint.

\tCotton-Base build
\t\t* make build-cotton-base-ios-release\t\t: Build cotton-base XCFramework for iOS.
\t\t* make build-cotton-base-android-release\t\t: Build & publish cotton-base to local Maven for Android.
\t\t* make build-cotton-base-release\t\t: Build cotton-base together for iOS & Android.
endef

export HELP_CONTENT

.PHONY: help
help:
	@printf "$$HELP_CONTENT\n"
