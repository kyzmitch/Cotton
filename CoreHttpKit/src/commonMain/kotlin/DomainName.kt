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
        val punycodedParts: List<String>
        try {
            // punycode function doesn't throw, but wrapping it just in case
            punycodedParts = parts.mapNotNull { if (it.isAscii) it else Punycode.encode(it) }
        } catch (e: Throwable) {
            throw Error.PunycodeFail()
        }

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

    val onlySecondLevelDomain: String
        get() {
            val parts = punycodedValue.split('.')
            if (parts.size < 2) {
                return punycodedValue
            }
            /**
             * a top level domain (TLD) – also called a domain name extension – is
             * the letter combination that concludes a web address
             * Of all TLDs, the most famous is .com.
             */
            val tld = parts.last()
            // second level domain
            val sld = parts.get(parts.size - 2)
            return sld + "." + tld
        }

    /**
     * Custom name to fix e.g. google.com when certificate from google only has www.google.com DNS name in it
     * Not sure why and how auth challenge was made before that
     * */
    val wwwName: String
        get() = "www." + onlySecondLevelDomain

    val wildcardName: String
        get() = "*." + onlySecondLevelDomain

    fun isSimilar(name: String): Boolean {
        return name.contains(punycodedValue) || punycodedValue.contains(name) || name == punycodedValue
    }

    sealed class Error(message: String) : Throwable(message) {
        class WrongLength(val inputLength: Int) : Error("wrong lenght: " + inputLength) {
            init {
                freeze()
            }
        }
        class EmptyString : Error("empty string") {
            init {
                freeze()
            }
        }
        class DotAtBeginning : Error("dot at beginning") {
            init {
                freeze()
            }
        }
        class DoubleDots : Error("double dots") {
            init {
                freeze()
            }
        }
        class WrongPartSize(val length: Int) : Error("wrong label size: " + length) {
            init {
                freeze()
            }
        }
        class PunycodingFailed : Error("punycode fail") {
            init {
                freeze()
            }
        }
        class NoDomainLabelParts : Error("no domain label parts") {
            init {
                freeze()
            }
        }
        class EmptyLastLabel : Error("last label is empty") {
            init {
                freeze()
            }
        }
        class RightmostDomainLabelStartsWithDigit : Error("trailing domain label starts with digit") {
            init {
                freeze()
            }
        }
        class PunycodeFail : Error("punycode util fail") {
            init {
                freeze()
            }
        }
    }
}
