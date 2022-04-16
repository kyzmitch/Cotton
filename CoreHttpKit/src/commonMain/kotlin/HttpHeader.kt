package org.cottonweb.CoreHttpKit

public enum class HTTPMethod(val stringValue: String) {
    GET("GET"),
    POST("POST")
}

public enum class ContentType(val stringValue: String) {
    Json("application/json"),
    /// The following type is used to indicate that the response will contain search suggestions.
    /// Link: [doc](http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0)
    JsonSuggestions("application/x-suggestions+json"),
    Url("application/x-www-form-urlencoded"),
    Html("text/html")
}

/// https://medium.com/@arturogdg/creating-enums-with-associated-data-in-kotlin-d9e2cdcf4a99
public sealed class HTTPHeader {
    class ContentType(val type: ContentType) : HTTPHeader()
    class ContentLength(val length: Int): HTTPHeader()
    class Accept(val type: ContentType) : HTTPHeader()
    class Authorization(val token: String) : HTTPHeader()
}