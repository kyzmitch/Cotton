package org.cottonweb.CoreHttpKit

enum class HttpScheme(val stringValue: String, val port: Int) {
    https("https", 80),
    http("http", 443)
}

interface ServerDescription {
    val hostString: String
    val domain: String
    val scheme: HttpScheme
        get() = HttpScheme.https
}
