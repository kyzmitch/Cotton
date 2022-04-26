package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

// https://kotlinlang.org/docs/whatsnew14.html#exception-handling-in-objective-c-swift-interop

/**
 * DNS name
 *
 * https://developers.google.com/speed/public-dns/docs/doh/json#supported_parameters
 * https://datatracker.ietf.org/doc/html/rfc4343
 *
 * @property input A string representation which has to be verified (should pe private because it wasn't checked for non ASCII symbols).
 * @property rawString A valid ASCII string with automatically converted symbols if they were non ASCII encoded.
 * */
final class DomainName(private val input: String) {
    private val punycodedValue: String
    val rawString: String
        get() = punycodedValue
    init {
        if (input.isEmpty()) {
            throw Error.EmptyString()
        }
        if (input.first() == '.') {
            throw Error.DotAtBeginning()
        }
        if (input.contains("..")) {
            throw Error.DoubleDots()
        }
        val length = input.length
        if (length < 1 || length > 253) {
            throw Error.WrongLength(length)
        }
        val parts = input.split('.')
        // https://tools.ietf.org/html/rfc5849#section-3.6
        // Non-ASCII characters should be punycoded (xn--qxam, not ελ).
        // Not using punycoding for the basic ASCII strings
        val punycodedParts = parts.mapNotNull { if (it.isAscii) it else Punycode.encode(it) }
        if (punycodedParts.size != parts.size) {
            throw Error.PunycodingFailed()
        }
        /**
         * The original DNS standard [STD13] had only two types:
         *
         * - ASCII labels, with a length from zero to 63 octets,
         * - indirect (or compression) labels,
         * which consist of an offset pointer to a name location
         * elsewhere in the wire encoding on a DNS message.
         * */
        punycodedParts.forEach {
            if (it.length > 63) {
                throw Error.WrongPartSize(it.length)
            }
        }
        punycodedValue = punycodedParts.joinToString(".")
        freeze()
    }

    sealed class Error : Throwable() {
        class WrongLength(val length: Int) : Error()
        class EmptyString : Error()
        class DotAtBeginning : Error()
        class DoubleDots : Error()
        class WrongPartSize(val length: Int) : Error()
        class PunycodingFailed : Error()
    }
}
