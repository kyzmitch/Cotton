package org.cottonweb.CoreHttpKit

import kotlin.text.encodeToByteArray
import kotlin.native.concurrent.freeze

/**
 * Response type which should be associated with specific Endpoint
 * and Server to accomplish some type safety and to not
 * have wrong decoding for HTTP response
 *
 * Would be good if this interface is based on some Decodable interface
 *
 * @property successCodes HTTP codes which could be used to determine the result of request
 * */
interface DecodableResponse {
    val successCodes: IntArray
        get() = intArrayOf(200, 201)
}

// https://kotlinlang.org/docs/kotlin-doc.html#block-tags

/**
 * The endpoint data type which describes some HTTP Rest request.
 * It connects to the specific server (host name) and
 * has a specific expected response type.
 *
 * We're not passing the Response type for now
 * because it is better for the Void response case
 * and currently we actually don't do network requests
 * in Kotlin, so, we don't need to decode the http responses
 * and no need to check the http response codes.
 * @property httpMethod usual HTTP methods like Get, Post, etc.
 * @property path slash divided string, e.g. `complete/search`
 * @property headers optional set of HTTP headers
 * @property encodingMethod The HTTP body encoding method like Query , Json, etc.
 * @constructor Creates the description for the Http request.
 */
data class Endpoint</* out R : DecodableResponse, */ in S : ServerDescription>(
    val httpMethod: HTTPMethod,
    val path: String,
    val headers: Set<HTTPHeader>?,
    val encodingMethod: ParametersEncodingDestination
) {
    init {
        // https://helw.net/2020/04/16/multithreading-in-kotlin-multiplatform-apps/
        // No need a static/companion fabric method for creation and calling next method
    }

    private fun buildParameters(items: Array<URLQueryPair>): String? {
        if (items.isEmpty()) { return null }
        var queryString: String = "?"
        for (queryParam in items) {
            val paramString: String
            if (queryParam.value.isBlank()) {
                // paramString = queryParam.name + "&"
                continue
            } else {
                // need to percent encode name & value
                paramString = queryParam.name.percentEncoded() + "=" + queryParam.value.percentEncoded() + "&"
            }
            // Ktor has `Byte.percentEncode` which is used inside
            queryString += paramString
        }
        return queryString.dropLast(1) // remove last '&'
    }

    private fun createQueryString(): String? {
        return when (encodingMethod) {
            is ParametersEncodingDestination.QueryString -> buildParameters(encodingMethod.items)
            else -> null
        }
    }

    private fun createHttpBodyData(): ByteArray? {
        return when (encodingMethod) {
            is ParametersEncodingDestination.HttpBody -> encodingMethod.encodedData
            is ParametersEncodingDestination.HttpBodyJSON -> encodingMethod.keyToValue.encode()
            else -> null
        }
    }

    private fun createRawURL(server: S): String {
        val scheme = server.scheme
        val rawURL: String = scheme.stringValue + "://" + server.host.rawString + ":" + scheme.port + "/" + path
        val queryUrlPart = createQueryString()
        if (queryUrlPart != null) {
            val builder = StringBuilder(rawURL)
            builder.append(queryUrlPart)
            return builder.toString()
        } else {
            return rawURL
        }
    }

    private fun createHeaders(accessToken: String?): Set<HTTPHeader> {
        var latestHeaders: MutableSet<HTTPHeader> = headers?.toMutableSet() ?: emptySet<HTTPHeader>().toMutableSet()
        accessToken?.let {
            val authHeader = HTTPHeader.Authorization(it)
            latestHeaders.add(authHeader)
        }
        val contentTypeHeader = encodingMethod.contentTypeHttpHeader
        latestHeaders.add(contentTypeHeader)
        return latestHeaders
    }

    fun request(server: S, requestTimeout: Long, accessToken: String?): HTTPRequestInfo {
        // need to create a raw URL and httpBody only
        val urlString: String = createRawURL(server)
        val httpBodyData: ByteArray? = createHttpBodyData()
        val updatedHeaders: Set<HTTPHeader> = createHeaders(accessToken)

        return HTTPRequestInfo(urlString, httpMethod, updatedHeaders, requestTimeout, httpBodyData)
    }
}

// extensions

internal fun Map<String, Any>.encode(): ByteArray {
    // https://github.com/Kotlin/kotlinx.serialization/issues/746
    val jsonObject = toJsonObject()
    val string = jsonObject.toString()
    return string.encodeToByteArray()
}
