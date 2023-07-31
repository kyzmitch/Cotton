![Cotton - web browser for iOS](catowseriOS/catowser/Assets.xcassets/AppIcon.appiconset/icon_83.5@2x.png)

# Cotton - web browser for iOS & Android

Features
-----------------
- web search autocomplete (DuckDuckGo, google)
- DNS over https (google) alpha state (can't fully support without VPN profiles)
- tabs
- favourite sites (hardcoded for now)
- supports ipad and iphone layouts
- settings
- ability to turn off the JavaScript for each tab
- tabs cache/restore to be able to see the same web sites after app restart
- own JavaScript plugins (instagram content downloads, html video tags downloads) experimental state

Building the code
-----------------
Environment
-----------------
IntelliJ IDEA 2022.2 (this is not latest version to avoid Android plugin error)
Xcode 14.2 is supported
Android Studio 2022.1.1 (Elecric Eel)

- Swift 5.7
- Kotlin 1.7.21 (not 1.8.0 because of used Android Studio stable version)
- Gradle 7.3 (Kotlin 1.8.0 fully supports Gradle versions 7.2 and 7.3)


Steps
-----------------
- install `Android Studio` to have Android SDK for Kotlin Multiplatform project even for iOS build, because gradle file depends on it as well.
- On macOS update your `.bash_profile` with
```
export ANDROID_HOME=/Users/<username>/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH="$PATH:/usr/local/Cellar/gradle@7/7.6.2/bin"
export PATH="$PATH:/Users/kyzmitch/.gem/ruby/2.6.0/bin"
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
- Run `cd cotton-base` & `gradle wrapper` if you see an error about Gradle build.
- `make`
- open Kotlin `cotton-base` folder using `InteliJ IDEA`
- run `cotton-base [assembleCottonBaseReleaseXCFramework]` Gradle configuration for iOS client. It is located under `other` section of Gradle tasks list.
- run `cotton-base [publishAndroidDebugPublicationToMavenLocal]` Gradle configuration for Android client
- for iOS client:
    - `cd catowseriOS/`
    - Open `catowser.xcworkspace`
    - Build `Cotton` or `Cotton dev` build target
- for Android client:
    - open `catowserAndroid` using Android Studio

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

