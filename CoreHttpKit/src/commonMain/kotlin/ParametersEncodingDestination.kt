package org.cottonweb.CoreHttpKit

/// URLSearchParams analog
data class URLQueryItem(val name: String, val value: String?)

sealed class ParametersEncodingDestination {
    class QueryString(val items: Array<URLQueryItem>): ParametersEncodingDestination()
    class HttpBodyJSON(val keyToValue: Map<String, Any>): ParametersEncodingDestination()
    class HttpBody(val encodedData: ByteArray): ParametersEncodingDestination()
}