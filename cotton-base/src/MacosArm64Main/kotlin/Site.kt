package org.cotton.base

import platform.Foundation.NSData
// import platform.AppKit.NSImage

actual typealias Image = NSData

actual fun Site.withFavicon(image: Image): Site? {
    return null
}

@ExperimentalUnsignedTypes
actual fun Site.favicon(): Image? {
    return null
}
