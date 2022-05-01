package org.cottonweb.CoreHttpKit

/**
 * A global regular exspression
 *
 * https://stackoverflow.com/a/3585284
 * */
@SharedImmutable
internal val asciiRegex = Regex("\\A\\p{ASCII}*\\z")
@SharedImmutable
internal const val upBound: Char = '\uD880'
@SharedImmutable
internal const val lowerBound: Char = '\uE000'
@SharedImmutable
internal const val secondUpBound: Char = '\uFFFF' // should be 0x1FFFFF

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
