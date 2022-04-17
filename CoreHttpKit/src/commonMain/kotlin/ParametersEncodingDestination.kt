package org.cottonweb.CoreHttpKit

/**
 * URLSearchParams analog from Apple and the value could be optional
 * On the other hand, Parameters can store only non optional pairs
 * */
data class URLQueryItem(val name: String, val value: String)

sealed class ParametersEncodingDestination {
    class QueryString(val items: Array<URLQueryItem>) : ParametersEncodingDestination()
    class HttpBodyJSON(val keyToValue: Map<String, Any>) : ParametersEncodingDestination()
    class HttpBody(val encodedData: ByteArray) : ParametersEncodingDestination()

    val contentTypeHttpHeader: HTTPHeader
        get() {
            val contentType: ContentTypeValue = when (this) {
                is QueryString -> ContentTypeValue.Url
                is HttpBodyJSON -> ContentTypeValue.Json
                is HttpBody -> ContentTypeValue.Json
            }
            return HTTPHeader.ContentType(contentType)
        }
}
