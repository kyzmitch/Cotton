SHELL := /bin/bash -o pipefail

RUBY_USER_DIR := $(shell ruby -r rubygems -e 'puts Gem.user_dir')

ifeq ($(RUBY_USER_DIR),)
$(error Unable to find ruby user install directory)
endif

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
	./gradlew assembleCottonBaseReleaseXCFramework; \
	export ANDROID_HOME=$HOME/Library/Android/sdk
	./gradlew publishAndroidDebugPublicationToMavenLocal; \
	cd ..; \
	cd catowserAndroid; \
	cd ..; \
	# TBD

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
	# TBD - somehow set homebrew path to bin to find gradle executable
	gradle wrapper; \
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
	gradle wrapper; \
	./gradlew assembleCottonBaseReleaseXCFramework; \
	ANDROID_HOME=~/Library/Android/sdk
	./gradlew publishAndroidReleasePublicationToMavenLocal; \
	cd ..; \
	cd catowserAndroid; \
	gradle wrapper; \
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
