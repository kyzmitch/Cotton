package org.cottonweb.CoreHttpKit

/**
 * Represents the URL host. Could be an ip v4 address or a domain name.
 *
 * https://tools.ietf.org/html/rfc1738#section-3.1
 *
 * @property input a raw string to verify if it is a host.
 * @property rawString a verified raw string representing the host value.
 * @property content a type of the host (ip address or a domain name).
 * */
final class Host @Throws(Host.Error::class) constructor (private val input: String) {
    private val validatedInputValue: String
    private val hostType: Content

    val rawString: String
        get() = validatedInputValue
    val content: Content
        get() = hostType

    companion object {
        /**
         * A regular expression to verify if a string is an ip v4 address
         *
         * https://stackoverflow.com/a/36760050
         * https://stackoverflow.com/a/37355379
         * */
        internal val ipV4Regex: Regex = Regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)(\\.(?!\$)|\$)){4}\$")
    }

    init {
        val inputWithoutDots = input.replace(".", "")
        val isIPv4address: Boolean
        if (inputWithoutDots.all { it.isDigit() }) {
            isIPv4address = input.matches(ipV4Regex)
        } else {
            isIPv4address = false
        }

        if (isIPv4address) {
            hostType = Content.IPv4
        } else {
            try { DomainName(input) } catch (e: DomainName.Error) { throw Error.NotValidHostInput(e) }
            hostType = Content.DomainName
        }

        validatedInputValue = input
    }

    /**
     * Note: only ip v4 addresses can be used for host name.
     * No mention of ip v6 addresses.
     * */
    enum class Content {
        /**
         * The fully qualified domain name of a network host
         * */
        DomainName,
        /**
         * its IP address as a set of four decimal digit groups separated by "."
         * */
        IPv4
    }

    sealed class Error : Throwable() {
        class NotValidHostInput(val err: DomainName.Error) : Host.Error()
    }
}
