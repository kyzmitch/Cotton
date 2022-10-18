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
1.`make`
2. open Kotlin CoreHttpKit folder using `InteliJ IDEA`
3. run `CoreHttpKit [assembleCoreHttpKitReleaseXCFramework]` Gradle configuration
4.`cd catowser/`
5.`pod install`
6. Open `catowser.xcworkspace`
7. Build `Cotton` or `Cotton dev` build target

Design documents
-----------------
Private repo https://github.com/kyzmitch/CatowserEvolution

## Dependencies
_____________________
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
Used to generate simple mocks for the unit tests. Can't be used for the Swift protocols with associated types.
https://github.com/krzysztofzablocki/Sourcery

## Screenshots

![ipad_landskape_screenshot](https://user-images.githubusercontent.com/622715/167244528-4cf58696-f191-4f96-b59f-e4956fcc429c.png)
![ipad_screenshot](https://user-images.githubusercontent.com/622715/167244530-7dd2931a-abbc-4804-a52d-e7d516e3ae5d.png)
![iphone_screenshot](https://user-images.githubusercontent.com/622715/167244532-f120c4f8-1570-4bc5-9caa-9fa0f0a6f47f.png)
![iphone_tabs_screenshot](https://user-images.githubusercontent.com/622715/167244534-ac07749d-788a-4e91-88dc-5a28f5439eb0.png)
