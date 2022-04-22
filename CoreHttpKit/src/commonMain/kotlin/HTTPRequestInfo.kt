package org.cottonweb.CoreHttpKit

import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.request.HttpRequestData
import io.ktor.http.content.ByteArrayContent
import kotlin.collections.HashSet
import kotlin.native.concurrent.freeze

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
) {
    init {
        freeze()
    }
    companion object {
        internal fun createFromKtorType(data: HttpRequestData): HTTPRequestInfo {
            val method: HTTPMethod = HTTPMethod.createFrom(data.method)
            val timeout = data.getCapabilityOrNull(HttpTimeout)?.requestTimeoutMillis ?: 60
            // no need to use a return statements inside the map lambda!
            // kotlin thinks that it is a return from the function
            val headers: List<HTTPHeader> = data.headers.entries().mapNotNull {
                it.takeIf { it.value.isNotEmpty() }?.let {
                    HTTPHeader.createFromRaw(it.key, it.value[0])
                }
            }

            val possibleHttpBody = data.body as? ByteArrayContent
            return HTTPRequestInfo(data.url.toString(), method, HashSet(headers), timeout, possibleHttpBody?.bytes())
        }
    }
}
