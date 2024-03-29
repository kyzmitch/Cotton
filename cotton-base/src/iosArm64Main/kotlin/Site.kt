package org.cotton.base

import kotlinx.cinterop.memScoped
import kotlinx.cinterop.readBytes
import kotlinx.cinterop.toCValues
import platform.Foundation.NSData
import platform.Foundation.dataWithBytes
import platform.UIKit.UIImage
import platform.UIKit.UIImagePNGRepresentation

actual typealias Image = UIImage

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
actual fun Site.withFavicon(image: Image): Site? {
    val data = UIImagePNGRepresentation(image)
    if (data == null) { return null }
    val bytesPtr = data.bytes
    if (bytesPtr == null) { return null }
    return Site(this.urlInfo, this.settings, bytesPtr.readBytes(data.length.toInt()))
}

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
actual fun Site.favicon(): Image? {
    if (faviconData == null) { return null }
    return memScoped {
        faviconData.toCValues()
            .ptr
            .let { NSData.dataWithBytes(it, faviconData.size.toULong()) }
            .let { UIImage.imageWithData(it) }
    }
}
