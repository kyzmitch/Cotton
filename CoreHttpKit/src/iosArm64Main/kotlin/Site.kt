package org.cottonweb.CoreBrowser

import kotlinx.cinterop.readBytes
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.toCValues
import platform.Foundation.NSData
import platform.Foundation.dataWithBytes
import platform.UIKit.UIImage
import platform.UIKit.UIImagePNGRepresentation

actual typealias Image = UIImage

actual fun Site.withFavicon(image: Image): Site? {
    val data = UIImagePNGRepresentation(image)
    if (data == null) { return null }
    val bytesPtr = data.bytes
    if (bytesPtr == null) { return null }
    return Site(this.urlInfo, this.settings, bytesPtr.readBytes(data.length.toInt()))
}

@ExperimentalUnsignedTypes
actual fun Site.favicon(): Image? {
    if (faviconData == null) { return null }
    return memScoped {
        faviconData.toCValues()
            .ptr
            .let { NSData.dataWithBytes(it, faviconData.size.toULong()) }
            .let { UIImage.imageWithData(it) }
    }
}
