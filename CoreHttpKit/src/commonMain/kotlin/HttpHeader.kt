package org.cottonweb.CoreHttpKit
import io.ktor.http.HttpMethod

enum class HTTPMethod(val stringValue: String) {
    GET("GET"),
    POST("POST");

    val ktorValue: HttpMethod
        get() {
            return when (this) {
                GET -> HttpMethod.Get
                POST -> HttpMethod.Post
            }
        }
}

enum class ContentTypeValue(val stringValue: String) {
    Json("application/json"),
    /**
     * The following type is used to indicate that the response will contain search suggestions.
     * Link: [doc](http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0)
     * */
    JsonSuggestions("application/x-suggestions+json"),
    Url("application/x-www-form-urlencoded"),
    Html("text/html")
}

// / https://medium.com/@arturogdg/creating-enums-with-associated-data-in-kotlin-d9e2cdcf4a99
sealed class HTTPHeader {
    class ContentType(val type: ContentTypeValue) : HTTPHeader()
    class ContentLength(val length: Int) : HTTPHeader()
    class Accept(val type: ContentTypeValue) : HTTPHeader()
    class Authorization(val token: String) : HTTPHeader()

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
