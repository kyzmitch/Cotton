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
1. `make`
2. open Kotlin CoreHttpKit folder using `InteliJ IDEA`
3. run `CoreHttpKit [assembleCoreHttpKitReleaseXCFramework]` Gradle configuration
4. `cd catowser/`
5. `pod install`
6. Open `catowser.xcworkspace`
7. Build `Cotton` or `Cotton dev` build target

Design documents
-----------------
https://github.com/kyzmitch/CatowserEvolution

## Screenshots

![ipad_landskape_screenshot](https://user-images.githubusercontent.com/622715/167244528-4cf58696-f191-4f96-b59f-e4956fcc429c.png)
![ipad_screenshot](https://user-images.githubusercontent.com/622715/167244530-7dd2931a-abbc-4804-a52d-e7d516e3ae5d.png)
![iphone_screenshot](https://user-images.githubusercontent.com/622715/167244532-f120c4f8-1570-4bc5-9caa-9fa0f0a6f47f.png)
![iphone_tabs_screenshot](https://user-images.githubusercontent.com/622715/167244534-ac07749d-788a-4e91-88dc-5a28f5439eb0.png)
