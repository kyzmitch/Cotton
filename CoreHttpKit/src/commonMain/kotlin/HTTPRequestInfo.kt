package org.cottonweb.CoreHttpKit

/**
 * A public HTTP request type used as a replacement
 * for some 3rd party library type to not expose it
 * on platform level and keep the type simple
 * */
data class HTTPRequestInfo(
    val rawURL: String,
    val method: HTTPMethod,
    val headers: Set<HTTPHeader>,
    val requestTimeout: Long,
    val httpBody: ByteArray? = null
)
