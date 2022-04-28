package org.cottonweb.CoreHttpKit

/**
 * Sadly but there is no way to import w3c url type
 * so that, have to use ktor types again
 *
 * import org.w3c.dom.url
 * */

/**
 * A regular expression to verify if a string is a ip v4 address
 *
 * https://stackoverflow.com/a/36760050
 * */
internal val ipV4Regex = Regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)(\\.(?!\$)|\$)){4}\$")

/**
 * Represents the host. Could be an ip address or a domain name.
 *
 * https://tools.ietf.org/html/rfc1738#section-3.1
 *
 * @property input a raw string to verify if it is a host.
 * */
final class Host @Throws(Host.Error::class) constructor (private val input: String) {
    private val validatedInputValue: String
    val rawString: String
        get() = validatedInputValue
    init {
        /**
         * https://tools.ietf.org/html/rfc1808#section-2.4
         * */
        if (input.contains("://")) {
            throw Error.ContainsBackslashPrefix()
        }

        val inputWithoutDots = input.replace(".", "")
        val isIPv4address: Boolean
        if (inputWithoutDots.all { it.isDigit() }) {
            isIPv4address = inputWithoutDots.matches(ipV4Regex)
        } else {
            isIPv4address = false
        }
        if (!isIPv4address) {
            try {
                DomainName(input)
            } catch (e: DomainName.Error) {
                throw Error.InvalidDomainName(e)
            }
        }

        validatedInputValue = input
    }

    sealed class Error : Throwable() {
        class ContainsBackslashPrefix : Host.Error()
        class InvalidDomainName(val err: DomainName.Error) : Host.Error()
    }
}
