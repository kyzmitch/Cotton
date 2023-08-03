package org.cotton.base

class ByteArrayNativeUtils private constructor() {
    companion object {}
}

expect class Data

expect fun ByteArrayNativeUtils.Companion.convertData(data: Data): ByteArray
expect fun ByteArrayNativeUtils.Companion.convertBytes(byteArray: ByteArray): Data
