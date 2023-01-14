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
final class Host @Throws(Host.Error::class) constructor (
    private val input: String
) {
    private val validatedInputValue: String
    private val hostType: Content
    private var domainName: DomainName? = null

    /**
     * Creates a Host instance based on Domain Name.
     *
     * It would be better thing to make this constructor main,
     * but at the same time it must not fail with any exception
     * because the input parameter is a valid DomainName
     *
     * @param domain A valid domain name
     * */
    constructor(domain: DomainName) : this(domain.rawString) {}

    internal val getDomainName: DomainName?
        get() = domainName

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

        /**
         * Some known domain names which are hard to load using ip address
         * without using VPN profile for DoH or when there is no access to URLRequest on iOS.
         * Other domain names usually can be loaded using our DoH implementation.
         * */
        internal val domainAccessibleOnlyHosts: Set<String> = setOf(
            "instagram.com",
            "www.instagram.com",
            "youtube.com",
            "m.youtube.com"
        )
    }

    init {
        val rawInputWithoutSpaces = input.withoutLeadingTrailingSpaces
        val inputWithoutDots = rawInputWithoutSpaces.replace(".", "")
        val isIPv4address: Boolean
        if (inputWithoutDots.all { it.isDigit() }) {
            // remove the leading & trailing spaces
            isIPv4address = rawInputWithoutSpaces.matches(ipV4Regex)
        } else {
            isIPv4address = false
        }

        if (isIPv4address) {
            hostType = Content.IPv4
        } else {
            try { domainName = DomainName(input) } catch (e: DomainName.Error) { throw Error.NotValidHostInput(e, input) }
            hostType = Content.DomainName
        }

        validatedInputValue = rawInputWithoutSpaces
    }

    /**
     * URLs with some hosts can't be loaded by ip address,
     * so that, DNS over HTTPS won't work for them using iOS WKWebView
     * since there is no way to change how URLRequest is doing DNS requests and replace them.
     */
    val isDoHSupported: Boolean
        get() {
            if (content == Content.IPv4) {
                return true
            }
            return !domainAccessibleOnlyHosts.contains(validatedInputValue)
        }

    val onlySecondLevelDomain: String?
        get() {
            if (content == Host.Content.IPv4) {
                return null
            }
            return domainName?.onlySecondLevelDomain
        }

    val wwwName: String?
        get() {
            if (content == Host.Content.IPv4) {
                return null
            }
            return domainName?.wwwName
        }

    val wildcardName: String?
        get() {
            if (content == Host.Content.IPv4) {
                return null
            }
            return domainName?.wildcardName
        }

    fun isSimilar(name: String): Boolean {
        return domainName?.isSimilar(name) ?: false
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        other as Host
        if (rawString != other.rawString) return false
        if (content != other.content) return false
        return true
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

    sealed class Error(message: String) : Throwable(message) {
        class NotValidHostInput(val err: DomainName.Error, val wrongInput: String) : Host.Error("input: " + wrongInput + ", error: " + err.message)
    }
}
