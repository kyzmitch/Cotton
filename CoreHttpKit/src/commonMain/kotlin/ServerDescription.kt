package org.cottonweb.CoreHttpKit

public enum class HttpScheme(val stringValue: String) {
    https("https"),
    http("http")
}

public interface Server {
    val hostString: String
    val domain: String
    val scheme: HttpScheme
        get() = HttpScheme.https
}