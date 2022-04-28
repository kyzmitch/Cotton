package org.cottonweb.CoreHttpKit

import kotlin.ranges.CharProgression
import kotlin.text.StringBuilder

// https://github.com/gumob/PunycodeSwift/blob/master/Source/Punycode.swift

/**
 * Punycode RFC 3492
 * See https://www.ietf.org/rfc/rfc3492.txt for standard details
 * */

internal class Punycode {
    private constructor() {
    }

    companion object {
        private val base: Int = 36
        private val tMin: Int = 1
        private val tMax: Int = 26
        private val skew: Int = 38
        private val damp: Int = 700
        private val initialBias: Int = 72
        private val initialN: Int = 128

        private val delimiter: Char = '-'
        private val lowercase = CharProgression.fromClosedRange('a', 'z', 1)
        private val digits = CharProgression.fromClosedRange('0', '9', 1)
        private val lettersBase: Int = 'a'.code
        private val digitsBase: Int = '0'.code

        private val ace: String = "xn--"

        private fun adaptBias(inputDelta: Int, numberOfPoints: Int, firstTime: Boolean): Int {
            var delta: Int = inputDelta
            if (firstTime) {
                delta /= damp
            } else {
                delta /= 2
            }
            delta += delta / numberOfPoints
            var k: Int = 0
            while (delta > ((base - tMin) * tMax) / 2) {
                delta /= base - tMin
                k += base
            }
            return k + ((base - tMin + 1) * delta) / (delta + skew)
        }

        /**
         * Maps an index to corresponding punycode character
         * */
        private fun punycodeValue(digit: Int): Char? {
            if (digit >= base) { return null }
            if (digit < 26) {
                return Char(lettersBase + digit)
            } else {
                return Char(digitsBase + digit - 26)
            }
        }

        /**
         * Encodes string to punycode (RFC 3492)
         *
         * There is an issue if you want to encode a basic ASCII string
         * this algo adds a trailing dash, so that, don't use it for ASCII values.
         *
         * @param input raw string
         * @return punycode encoded string
         * */
        internal fun encode(input: String): String? {
            var n: Int = initialN
            var delta: Int = 0
            var bias: Int = initialBias
            var output = StringBuilder()
            input.toCharArray().forEach {
                if (it.isAscii) {
                    output.append(it)
                } else if (!it.isValid) {
                    // Encountered a scalar out of acceptable range
                    return null
                }
            }

            var handled: Int = output.length
            var basic: Int = handled
            if (basic > 0) {
                output.append(delimiter)
            }

            while (handled < input.length) {
                var minimumCodepoint: Int = 0x10FFFF
                input.forEach {
                    if (it.code < minimumCodepoint && it.code >= n) {
                        minimumCodepoint = it.code
                    }
                }
                delta += (minimumCodepoint - n) * (handled + 1)
                n = minimumCodepoint

                input.forEach {
                    if (it.code < n) {
                        delta += 1
                    } else if (it.code == n) {
                        var q: Int = delta
                        var k: Int = base
                        while (true) {
                            val t: Int
                            if (k <= bias) {
                                t = tMin
                            } else {
                                if (k >= bias + tMax) {
                                    t = tMax
                                } else {
                                    t = k - bias
                                }
                            }
                            if (q < t) {
                                break
                            }
                            val charCode = t + ((q - t) % (base - t))
                            val punycodedChar: Char? = punycodeValue(charCode)
                            if (punycodedChar == null) {
                                return null
                            }
                            output.append(punycodedChar)
                            q = (q - t) / (base - t)
                            k += base
                        }
                        val nextPunycodedChar: Char? = punycodeValue(q)
                        if (nextPunycodedChar == null) {
                            return null
                        }
                        output.append(nextPunycodedChar)
                        bias = adaptBias(delta, handled + 1, handled == basic)
                        delta = 0
                        handled += 1
                    }
                }

                delta += 1
                n += 1
            }

            return output.toString()
        }
    }
}
