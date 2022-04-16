package org.cottonweb.CoreHttpKit
import io.ktor.client.plugins.timeout
import io.ktor.client.request.headers
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.client.request.HttpRequestData
import io.ktor.client.request.url
import io.ktor.http.Parameters
import io.ktor.http.ParametersBuilder
import io.ktor.http.Url
import io.ktor.http.URLBuilder
import io.ktor.http.URLProtocol

/**
 * Would be good if this interface is based on some Decodable interface
 * */
interface ResponseType {
    val successCodes: IntArray
        get() = intArrayOf(200, 201)
}

// https://kotlinlang.org/docs/kotlin-doc.html#block-tags

/**
 * The endpoint data type.
 *
 * @property path slash divided string, e.g. `complete/search`
 * @constructor Creates the description for the Http request.
 */
data class Endpoint<out R : ResponseType, in S : Server>(
    val httpMethod: HTTPMethod,
    val path: String,
    val headers: Set<HTTPHeader>?,
    val encodingMethod: ParametersEncodingDestination
) {
    fun urlRelatedTo(server: S): Url {
        val scheme = server.scheme
        val urlProtocol = URLProtocol(scheme.stringValue, scheme.port)
        val pathSegments = path.split('/')
        val parameters = urlParameters()
        // https://github.com/ktorio/ktor/blob/main/ktor-http/common/src/io/ktor/http/URLBuilder.kt
        val builder = URLBuilder(
            urlProtocol,
            server.hostString,
            scheme.port,
            null,
            null,
            pathSegments,
            parameters
        )
        return builder.build()
    }

    fun request(url: Url, requestTimeout: Long, accessToken: String?): HttpRequestData /*HttpRequest*/ {
        var builder = HttpRequestBuilder()
        builder.method = httpMethod.ktorValue
        builder.timeout {
            this.requestTimeoutMillis = requestTimeout
        }
        builder.url(url)
        headers?.let {
            builder.headers {
                it.forEach { this.append(it.key, it.value) }
            }
        }
        accessToken?.let {
            val authHeader = HTTPHeader.Authorization(it)
            builder.headers {
                this.append(authHeader.key, authHeader.value)
            }
        }

        return builder.build()
    }

    private fun urlParameters(): Parameters {
        return when (encodingMethod) {
            is ParametersEncodingDestination.QueryString -> buildParameters(encodingMethod.items)
            else -> Parameters.Empty
        }
    }

    private fun buildParameters(items: Array<URLQueryItem>): Parameters {
        if (items.isEmpty()) return Parameters.Empty
        val parametersBuilder = ParametersBuilder(items.size)
        items.forEach { parametersBuilder.append(it.name, it.value) }
        return parametersBuilder.build()
    }
}
