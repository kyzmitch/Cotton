package org.cotton.base

import kotlin.ByteArray

actual typealias Data = Int

actual fun ByteArrayNativeUtils.Companion.convertData(data: Data): ByteArray {
    return ByteArray(0)
}

actual fun ByteArrayNativeUtils.Companion.convertBytes(byteArray: ByteArray): Data {
    return 0
}
