SHELL := /bin/bash -o pipefail

RUBY_USER_DIR := $(shell ruby -r rubygems -e 'puts Gem.user_dir')

ifeq ($(RUBY_USER_DIR),)
$(error Unable to find ruby user install directory)
endif

.PHONY: setup-ios
setup-ios:
	gem install bundler -v '~> 1.0' --user-install
	$(DISPLAY_SEPARATOR)
	brew update
	$(DISPLAY_SEPARATOR)
	brew bundle install --file=./brew_configs/Brewfile
	mint install MakeAWishFoundation/SwiftyMocky
	cd cotton-base; gradle wrapper; ./gradlew assembleCottonBaseReleaseXCFramework; cd ..; \
	cd catowseriOS; xcodebuild -workspace catowser.xcworkspace -scheme "Cotton dev" -configuration "Release" -sdk iphonesimulator -arch x86_64; cd ..; \

.PHONY: build-ios-dev-release
build-ios-dev-release:
	cd cotton-base; gradle wrapper; ./gradlew assembleCottonBaseReleaseXCFramework; cd ..; \
	cd catowseriOS; xcodebuild -workspace catowser.xcworkspace -scheme "Cotton dev" -configuration "Release" -sdk iphonesimulator -arch x86_64; cd ..; \

.PHONY: clean
clean:
	cd cotton-base; rm -rf build; cd ..; \
	cd catowseriOS; rm -rf Build; cd ..; \
	cd catowserAndroid; rm -rf build; cd ..; \
