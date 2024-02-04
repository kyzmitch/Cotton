![Cotton - web browser for iOS](catowseriOS/catowser/Assets.xcassets/AppIcon.appiconset/icon_83.5@2x.png)

# Cotton - web browser for iOS & Android

## Features
- web search autocomplete (DuckDuckGo, google)
- DNS over https (google) alpha state (can't fully support without VPN profiles)
- tabs
- favourite sites (hardcoded for now)
- supports ipad and iphone layouts
- settings
- ability to turn off the JavaScript for each tab
- tabs cache/restore to be able to see the same web sites after app restart
- own JavaScript plugins (instagram content downloads, html video tags downloads) experimental state

## Building the code
### Environment
- IntelliJ IDEA 2023.2.4 (Community Edition)
- Xcode 15.0.0
- Android Studio Giraffe | 2022.3.1 Patch 4

- Swift 5.9
- Kotlin 1.9.20
- Gradle 7.4.2 for build.gradle.kts in IndelliJ IDEA, but can use 8.1 in wrapper. In Android Studio it is 7.3.0 in build.gradle.kts and 7.4 in wrapper.

### Steps
#### Make commands
If you have everything installed, then use `make help` to see how to build `cotton-base` which is needed for Xcode project, if no, then do the following steps

#### Full clear setup
- install `Android Studio` to have Android SDK for Kotlin Multiplatform project even for iOS build, because gradle file depends on it as well.
- On macOS update your `.bash_profile` with
```
export ANDROID_HOME=/Users/<username>/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH="$PATH:/usr/local/Cellar/gradle@7/7.6.2/bin"
```
- run `source .bash_profile`
- install `InteliJ IDEA`
- Add `ANDROID_HOME` to path variables of `InteliJ IDEA` in settings or put `local.properties` file with the following content:
  ```
  sdk.dir=/Users/kyzmitch/Library/Android/sdk
  ```
- To fix `License for package Android SDK Platform 32 not accepted.` in `InteliJ IDEA`
    - Tools -> Android -> SDK Manager
    - SDK Tools tab
    - Install `Google Play Licensing Library`

#### CottonBase common dependency
##### for iOS client
- run `make build-cotton-base-ios-release`
- `cd catowseriOS/`
- `open catowser.xcworkspace`
- Build `Cotton` or `Cotton dev` build target from Xcode

##### for Android client
1. if you use Terminal run `make build-cotton-base-android-release`
2. if you use IntelliJ IDEA run `cotton-base [publishAndroidDebugPublicationToMavenLocal]` Gradle task

Open `catowserAndroid` folder using Android Studio after that.

Design documents
-----------------
Private repo https://github.com/kyzmitch/CatowserEvolution

Dependencies
-----------------

### SwiftSoup
Used to parse HTML content of the loaded web pages to extract video tags and other info. 
https://github.com/scinfu/SwiftSoup
### Alamofire
Used as current transport for the REST calls. Can be replaced easily with something else. 
https://github.com/Alamofire/Alamofire 
### ReactiveSwift
Used to be main API for async source code. Some places are already migrated to Combine or Concurrency, but not all. It is possible to change currently used Async API. 
https://github.com/ReactiveCocoa/ReactiveSwift
### SWXMLHash
Used to parse OpenSearch XML files which described search plugins. To be able to extend currently used search providers by including new XML files.
https://github.com/drmohundro/SWXMLHash
### AlamofireImage
Used to download favicons for the web sites.
https://github.com/Alamofire/AlamofireImage
### SwiftLint
Compile/Run time checks for Swift source code. 
https://github.com/realm/SwiftLint
### Sourcery
Used to generate simple mocks. Can't be used for the Swift protocols with associated types.
https://github.com/krzysztofzablocki/Sourcery
### SwiftyMocky
Used to generate complex mocks for the types and Swift protocols with associated types and constraints. 
https://github.com/MakeAWishFoundation/SwiftyMocky

