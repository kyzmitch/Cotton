package org.cotton.base

import kotlin.ByteArray

actual typealias Image = ByteArray

actual fun Site.withFavicon(image: Image): Site? {
    return null
}

@ExperimentalUnsignedTypes
actual fun Site.favicon(): Image? {
    return null
}