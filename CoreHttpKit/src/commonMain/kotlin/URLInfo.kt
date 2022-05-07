package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

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

    val ipAddressString: String?
        get() = ipAddress

    private val completePath: String
        get() {
            if (query != null) {
                return path + "?" + query
            } else {
                return path
            }
        }

    init {
        url = scheme.stringValue + "://" + domainName.rawString + ":" + scheme.port + "/" + completePath
        freeze()
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
     * instead of a domain name it will give the ip address.
     *
     * Returning the original URL when ip address is not present.
     * */
    fun urlWithIPaddress(): String {
        if (ipAddress == null) {
            return url
        }
        return scheme.stringValue + "://" + ipAddress + ":" + scheme.port + "/" + completePath
    }

    fun host(): Host {
        return Host(domainName)
    }
}
