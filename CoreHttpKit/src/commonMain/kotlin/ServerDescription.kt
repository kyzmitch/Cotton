package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

enum class HttpScheme(val stringValue: String, val port: Int) {
    https("https", 443),
    http("http", 80)
}

// https://blog.kotlin-academy.com/abstract-class-vs-interface-in-kotlin-5ab8697c3a14

/**
 * A server description base interface
 *
 * @property hostString A raw string (could contain dots and domains)
 * @property domain The minimum part of the host
 * @property scheme Server protocol type (could be HTTPS, HTTP, etc.)
 * */
/* interface */ abstract class ServerDescription {
    /**
     * TODO: use Host type instead of a raw string
     * */
    abstract val hostString: String
    abstract val domain: String
    val scheme: HttpScheme
        get() = HttpScheme.https
    init {
        freeze()
    }
}
