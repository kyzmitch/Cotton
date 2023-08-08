package org.cotton.base

import kotlin.text.encodeToByteArray

/**
 * A global regular exspression
 *
 * https://stackoverflow.com/a/3585284
 * */
internal val asciiRegex = Regex("\\A\\p{ASCII}*\\z")

internal const val upBound: Char = '\uD880'

internal const val lowerBound: Char = '\uE000'

internal const val secondUpBound: Char = '\uFFFF' // should be 0x1FFFFF

internal val urlAlphabet = (('a'..'z') + ('A'..'Z') + ('0'..'9')).map { it.code.toByte() }

/**
 * Oauth specific percent encoding
 * https://tools.ietf.org/html/rfc5849#section-3.6
 */

internal val oauthSymbols = listOf('-', '.', '_', '~').map { it.code.toByte() }

internal val Char.isAscii: Boolean
    get() {
        return "$this".matches(asciiRegex)
    }

internal val Char.isValid: Boolean
    get() {
        return this < upBound || (this >= lowerBound && this <= secondUpBound)
    }

internal val String.isAscii: Boolean
    get() {
        return matches(asciiRegex)
    }

/**
 * Trim leading and trailing space characters.
 * This property is public only for unit tests.
 * */
val String.withoutLeadingTrailingSpaces: String
    get() {
        if (isEmpty()) {
            return this
        }
        var front = 0
        while (get(front) == ' ') {
            front++
        }
        var end = length - 1
        while (get(end) == ' ') {
            end--
        }
        return subSequence(front, end + 1).toString()
    }

internal fun hexDigitToChar(digit: Int): Char = when (digit) {
    in 0..9 -> '0' + digit
    else -> 'A' + digit - 10
}

internal fun Byte.percentEncode(): String = buildString(3) {
    val code = toInt() and 0xff
    append('%')
    append(hexDigitToChar(code shr 4))
    append(hexDigitToChar(code and 0x0f))
}

/**
 * Creates a percent encoded version of the string for URL.
 * */
internal fun String.percentEncoded(spaceToPlus: Boolean = false): String = buildString {
    var bytes: ByteArray = encodeToByteArray()
    for (i in 0..bytes.size - 1) {
        val byte = bytes.get(i)
        when {
            byte in urlAlphabet || byte in oauthSymbols -> append(byte.toInt().toChar())
            spaceToPlus && byte == ' '.code.toByte() -> append('+')
            else -> append(byte.percentEncode())
        }
    }
}
