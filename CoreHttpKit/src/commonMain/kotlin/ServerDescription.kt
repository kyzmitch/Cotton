package org.cottonweb.CoreHttpKit

enum class HttpScheme(val stringValue: String, val port: Int) {
    https("https", 443),
    http("http", 80)
}

// https://blog.kotlin-academy.com/abstract-class-vs-interface-in-kotlin-5ab8697c3a14

/* interface */ abstract class ServerDescription {
    abstract val hostString: String
    abstract val domain: String
    val scheme: HttpScheme
        get() = HttpScheme.https
}
