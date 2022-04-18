package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

/**
 * URLSearchParams analog from Apple and the value could be optional
 * On the other hand, Parameters can store only non optional pairs
 * */
data class URLQueryPair(val name: String, val value: String) {
    init {
        freeze()
    }
}

sealed class ParametersEncodingDestination {
    class QueryString(val items: Array<URLQueryPair>) : ParametersEncodingDestination() {
        init {
            freeze()
        }
    }
    class HttpBodyJSON(val keyToValue: Map<String, Any>) : ParametersEncodingDestination() {
        init {
            freeze()
        }
    }
    class HttpBody(val encodedData: ByteArray) : ParametersEncodingDestination() {
        init {
            freeze()
        }
    }

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
