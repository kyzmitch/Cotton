![Cotton - web browser for iOS](catowser/catowser/Assets.xcassets/AppIcon.appiconset/icon_83.5@2x.png)

# Cotton - web browser for iOS

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
- install `Android Studio` to have Android SDK for Kotlin Multiplatform project even for iOS build, because gradle file depends on it as well.
- On macOS update your `.bash_profile` with
```
export ANDROID_HOME=/Users/<username>/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator
```
- run `source .bash_profile`
- install `InteliJ IDEA`
- Add `ANDROID_HOME` to path variables of `InteliJ IDEA` in settings.
- To fix `License for package Android SDK Platform 32 not accepted.` in `InteliJ IDEA`
    - Tools -> Android -> SDK Manager
    - SDK Tools tab
    - Install `Google Play Licensing Library`
- `make`
- open Kotlin CoreHttpKit folder using `InteliJ IDEA`
- run `CoreHttpKit [assembleCoreHttpKitReleaseXCFramework]` Gradle configuration
- `cd catowser/`
- Open `catowser.xcworkspace`
- Build `Cotton` or `Cotton dev` build target

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

