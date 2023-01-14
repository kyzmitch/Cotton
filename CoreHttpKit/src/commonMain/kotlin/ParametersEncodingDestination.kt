package org.cottonweb.CoreHttpKit

/**
 * Analog from Apple where the value could be optional
 * On the other hand, Parameters can store only non optional pairs
 *
 * @property name The name of the query parameter
 * @property value Non-optional value for the query parameter
 * */
data class URLQueryPair(val name: String, val value: String)

/**
 * HTTP parameters encoding method
 * which can be used to set the HttpBody property
 * of the actual Http request.
 * */
sealed class ParametersEncodingDestination {
    class QueryString(val items: Array<URLQueryPair>) : ParametersEncodingDestination()
    class HttpBodyJSON(val keyToValue: Map<String, Any>) : ParametersEncodingDestination()
    class HttpBody(val encodedData: ByteArray) : ParametersEncodingDestination()

    internal val contentTypeHttpHeader: HTTPHeader
        get() {
            val contentType: ContentTypeValue = when (this) {
                is QueryString -> ContentTypeValue.Url
                is HttpBodyJSON -> ContentTypeValue.Json
                is HttpBody -> ContentTypeValue.Json
            }
            return HTTPHeader.ContentType(contentType)
        }
}
