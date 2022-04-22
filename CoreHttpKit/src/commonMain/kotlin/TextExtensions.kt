package org.cottonweb.CoreHttpKit

/**
 * A global regular exspression
 *
 * https://stackoverflow.com/a/3585284
 * */
internal val asciiRegex = Regex("\\A\\p{ASCII}*\\z")
internal const val upBound: Char = '\uD880'
internal const val lowerBound: Char = '\uE000'
internal const val secondUpBound: Char = '\uFFFF' // should be 0x1FFFFF

val Char.isAscii: Boolean
    get() {
        return "$this".matches(asciiRegex)
    }

val Char.isValid: Boolean
    get() {
        return this < upBound || (this >= lowerBound && this <= secondUpBound)
    }

val String.isAscii: Boolean
    get() {
        return matches(asciiRegex)
    }
