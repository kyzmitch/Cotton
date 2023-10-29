package org.cotton.base

import kotlinx.cinterop.addressOf
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.create
import platform.posix.memcpy

actual typealias Data = NSData

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
actual fun ByteArrayNativeUtils.Companion.convertData(data: Data): ByteArray {
    return data.bytes?.let { bytes ->
        ByteArray(data.length.toInt()).apply {
            usePinned { pinned ->
                memcpy(pinned.addressOf(0), bytes, data.length)
            }
        }
    } ?: ByteArray(0)
}

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class, kotlinx.cinterop.BetaInteropApi::class)
actual fun ByteArrayNativeUtils.Companion.convertBytes(byteArray: ByteArray): Data {
    return byteArray.usePinned {
        NSData.create(
            bytes = it.addressOf(0),
            length = byteArray.size.toULong()
        )
    }
}
