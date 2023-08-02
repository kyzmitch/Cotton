SHELL := /bin/bash -o pipefail

RUBY_USER_DIR := $(shell ruby -r rubygems -e 'puts Gem.user_dir')

ifeq ($(RUBY_USER_DIR),)
$(error Unable to find ruby user install directory)
endif

GRADLE = /usr/local/opt/gradle@7/bin/gradle
# bash profile update every time is not a good option
# echo 'export PATH="/usr/local/opt/gradle@7/bin:$PATH"' >> ~/.bash_profile ; \

.PHONY: github-workflow-ios
github-workflow-ios:
	cd cotton-base; \
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
	echo "sdk.dir=~/Library/Android/sdk" > local.properties; \
	export ANDROID_HOME=~/Library/Android/sdk; \
	$(call GRADLE, wrapper); \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	./gradlew publishAndroidDebugPublicationToMavenLocal; \
	cd ..; \
	cd catowserAndroid; \
	echo "sdk.dir=~/Library/Android/sdk" > local.properties; \
	$(call GRADLE, wrapper); \
	./gradlew build; \
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
build-ios-dev-release:
	cd cotton-base; \
	$(call GRADLE, wrapper); \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	cd ..; \
	cd catowseriOS; \
	xcodebuild -scheme "Cotton dev" build \
	 -workspace catowser.xcworkspace \
	 -quiet \
	 -configuration "Release" \
	 -sdk iphonesimulator \
	 -arch x86_64; \
	 cd ..; \

.PHONY: build-android-dev-release
build-android-dev-release:
	cd cotton-base; \
	echo "sdk.dir=~/Library/Android/sdk" > local.properties; \
	export ANDROID_HOME=~/Library/Android/sdk; \
	$(call GRADLE, wrapper); \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	./gradlew publishAndroidReleasePublicationToMavenLocal; \
	cd ..; \
	cd catowserAndroid; \
	echo "sdk.dir=~/Library/Android/sdk" > local.properties; \
	$(call GRADLE, wrapper); \
	./gradlew build; \
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

define HELP_CONTENT
Local and CI targets
\tUniversal targets
\t\t* make setup\t\t: Downloads local dependencies like SwiftLint, KtLint, Gradle for command line, etc.
\t\t* make clean\t\t: Cleans all build artifacts for both platforms.

\tiOS build
\t\t* make build-ios-dev-release\t\t: Build Release version of Kotlin multiplatform & Xcode project.
\t\t* make github-workflow-ios\t\t: GitHub workflow for iOS.

\tAndroid build
\t\t* make build-android-dev-release\t\t: Build Release version of Kotlin multiplatform & Android project.
\t\t* make github-workflow-android\t\t: GitHub workflow for Android.
endef

export HELP_CONTENT

.PHONY: help
help:
	@printf "$$HELP_CONTENT\n"