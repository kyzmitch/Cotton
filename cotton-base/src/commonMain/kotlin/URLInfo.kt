package org.cotton.base

/**
 * URL type with ip address info.
 * The ip address info usually filled in after DNS over HTTPS request.
 * This allow to have HTTP request for URL without domain name information,
 * to not disclose the visited web sites for privacy.
 *
 * NOTE: still, older TLS protocol versions show the domain name info.
 *
 * @property scheme A URL prefix describing the protocol name
 * @property path The string contatining the path of URL and query parameters
 * @property domainName A name of the server
 * @property ipAddress A replacement for the domain name.
 * */
class URLInfo constructor(
    private val scheme: HttpScheme,
    private val path: String,
    private val query: String? = null,
    val domainName: DomainName,
    private var ipAddress: String? = null
) {

    /**
     * Returns the URL string with domain name even if there is an ip address.
     * */
    val url: String
        get() = scheme.stringValue + "://" + domainName.rawString + ":" + scheme.port + "/" + completePath

    /**
     * Returns the URL string with domain name and without port number
     */
    val urlWithoutPort: String
        get() = scheme.stringValue + "://" + domainName.rawString + "/" + completePath

    val ipAddressString: String?
        get() = ipAddress

    private val completePath: String
        get() {
            val result: String
            if (query != null) {
                result = path + "?" + query
            } else {
                result = path
            }

            /**
             * the Path part of the iOS URL contains the `/` prefix right away
             * so that, we have to remove it or not use the slash later.
             * */
            if (!result.isEmpty() && result.first() == '/') {
                return result.drop(1)
            } else {
                return result
            }
        }

    /**
     * The IP address of the domain name from the initial URL is usually unknown at the start.
     * So that, with this property setter we're allowing to set it later.
     * And it will be used next time the user of this type decides to
     * get a URL string, and next time it will contain the ip address instead of a domain name.
     * */
    fun withIPAddress(ipAddress: String): URLInfo {
        // Initially I wanted to have a property which mutates the instance
        // but it won't work when we use freeze function
        // So that, to keep immutability - this create a copy with a new field
        return URLInfo(scheme, path, query, domainName, ipAddress)
    }

    /**
     * When ip address is present, this property could return the same initial URL, but
     * instead of a domain name it will give the ip address. Also contains a port number.
     *
     * Returning the original URL when ip address is not present.
     * */
    fun urlWithIPaddress(): String {
        if (ipAddress == null) {
            return url
        }
        return scheme.stringValue + "://" + ipAddress + ":" + scheme.port + "/" + completePath
    }

    /**
     * When ip address is present, this property could return the same initial URL, but
     * instead of a domain name it will give the ip address.
     *
     * Returning the original URL when ip address is not present.
     * */
    fun urlWithIPaddressWithoutPort(): String {
        if (ipAddress == null) {
            return url
        }
        return scheme.stringValue + "://" + ipAddress + "/" + completePath
    }

    fun host(): Host {
        return Host(domainName)
    }

    /**
     * FavIcon of website using resolved domain name ip address if it is present
     *
     */
    val faviconURLFromIp: String?
        get() {
            if (ipAddress != null) {
                return "https://" + ipAddress + "/favicon.ico"
            } else {
                return null
            }
        }

    /**
     * FavIcon of website using domain name
     */
    val faviconURLFromDomain: String
        get() = "https://" + domainName.rawString + "/favicon.ico"

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        other as URLInfo
        if (domainName != other.domainName) return false
        if (ipAddress != other.ipAddress) return false
        if (scheme != other.scheme) return false
        if (completePath != other.completePath) return false
        if (query != other.query) return false
        return true
    }
}
