package org.cotton.base

/**
 * Basic HTTP method
 * */
enum class HTTPMethod(val stringValue: String) {
    GET("GET"),
    POST("POST");

    companion object {
        fun createFrom(rawString: String): HTTPMethod? {
            return when (rawString) {
                "GET" -> HTTPMethod.GET
                "POST" -> HTTPMethod.POST
                else -> null
            }
        }
    }
}

/**
 * Content type for HTTP header value
 * */
enum class ContentTypeValue(val stringValue: String) {
    Json("application/json"),

    /**
     * The following type is used to indicate that the response will contain search suggestions.
     * Link: [doc](http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0)
     * */
    JsonSuggestions("application/x-suggestions+json"),
    Url("application/x-www-form-urlencoded"),
    Html("text/html");

    companion object {
        fun createFrom(rawValue: String): ContentTypeValue? {
            return when (rawValue) {
                "application/json" -> Json
                "application/x-suggestions+json" -> JsonSuggestions
                "application/x-www-form-urlencoded" -> Url
                "text/html" -> Html
                else -> null
            }
        }
    }
}

/**
 * HTTP header type using nested sealed classes
 * */
sealed class HTTPHeader {
    class ContentType(val type: ContentTypeValue) : HTTPHeader()
    class ContentLength(val length: Int) : HTTPHeader()
    class Accept(val type: ContentTypeValue) : HTTPHeader()
    class Authorization(val token: String) : HTTPHeader()

    companion object {
        internal fun createFromRaw(name: String, value: String): HTTPHeader? {
            return when (name) {
                "Content-Type" -> ContentTypeValue.createFrom(value)?.let { ContentType(it) }
                "Content-Length" -> value.toIntOrNull()?.let { ContentLength(it) }
                "Accept" -> ContentTypeValue.createFrom(value)?.let { Accept(it) }
                "Authorization" -> Authorization(value)
                else -> null
            }
        }
    }

    val key: String
        get() {
            return when (this) {
                is ContentType -> "Content-Type"
                is ContentLength -> "Content-Length"
                is Accept -> "Accept"
                is Authorization -> "Authorization"
            }
        }

    val value: String
        get() {
            return when (this) {
                is ContentType -> type.stringValue
                is ContentLength -> "$length"
                is Accept -> type.stringValue
                is Authorization -> "Bearer $token"
            }
        }
}
