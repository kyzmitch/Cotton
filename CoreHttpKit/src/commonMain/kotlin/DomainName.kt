package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

/**
 * Domain name.
 *
 * https://datatracker.ietf.org/doc/html/rfc1034#section-3.5
 *
 * @property input A string representation which has to be verified (should pe private because it wasn't checked for non ASCII symbols).
 * @property rawString A valid ASCII string with automatically converted symbols if they were non ASCII encoded.
 * */
final class DomainName @Throws(DomainName.Error::class) constructor(private val input: String) {
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
        val parts: List<String> = input.split('.')
        if (parts.isEmpty()) {
            throw Error.NoDomainLabelParts()
        }
        /**
         * The rightmost domain label will never start with a digit, though, which
         * syntactically distinguishes all domain names from the IP addresses.
         *
         * https://datatracker.ietf.org/doc/html/rfc1123#section-2.1
         * */
        val lastLabel: String = parts.get(parts.size - 1)
        if (lastLabel.isEmpty()) {
            throw Error.EmptyLastLabel()
        }
        val looksLikeIPv4Address: Boolean = lastLabel.first().isDigit()
        if (looksLikeIPv4Address) {
            throw Error.RightmostDomainLabelStartsWithDigit()
        }

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
        class WrongLength(val inputLength: Int) : Error()
        class EmptyString : Error()
        class DotAtBeginning : Error()
        class DoubleDots : Error()
        class WrongPartSize(val length: Int) : Error()
        class PunycodingFailed : Error()
        class NoDomainLabelParts : Error()
        class EmptyLastLabel : Error()
        class RightmostDomainLabelStartsWithDigit : Error()
    }
}
