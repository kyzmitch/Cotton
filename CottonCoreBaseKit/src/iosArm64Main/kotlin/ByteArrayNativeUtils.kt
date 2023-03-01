package org.cotton.base

// https://stackoverflow.com/a/34625454
// Your InteliJ IDEA kotlin plugin version should match the kotlin version used in build.gradle.kts
// If it is not, then kotlinx reference in the below import won't be resolved

import kotlinx.cinterop.addressOf
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.create
import platform.posix.memcpy

actual typealias Data = NSData

@ExperimentalUnsignedTypes
actual fun ByteArrayNativeUtils.Companion.convertData(data: Data): ByteArray {
    return data.bytes?.let { bytes ->
        ByteArray(data.length.toInt()).apply {
            usePinned { pinned ->
                memcpy(pinned.addressOf(0), bytes, data.length)
            }
        }
    } ?: ByteArray(0)
}

@ExperimentalUnsignedTypes
actual fun ByteArrayNativeUtils.Companion.convertBytes(byteArray: ByteArray): Data {
    return byteArray.usePinned {
        NSData.create(
            bytes = it.addressOf(0),
            length = byteArray.size.toULong()
        )
    }
}