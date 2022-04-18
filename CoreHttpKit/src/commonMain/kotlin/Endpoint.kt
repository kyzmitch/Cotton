package org.cottonweb.CoreHttpKit
import io.ktor.client.plugins.timeout
import io.ktor.client.request.headers
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.client.request.setBody
import io.ktor.client.request.url
import io.ktor.http.Parameters
import io.ktor.http.ParametersBuilder
import io.ktor.http.Url
import io.ktor.http.URLBuilder
import io.ktor.http.URLProtocol
import io.ktor.http.ContentType
import io.ktor.http.content.ByteArrayContent
import io.ktor.utils.io.charsets.Charsets
import io.ktor.utils.io.core.toByteArray
import kotlin.native.concurrent.freeze

/**
 * Would be good if this interface is based on some Decodable interface
 * */
interface DecodableResponse {
    val successCodes: IntArray
        get() = intArrayOf(200, 201)
}

// https://kotlinlang.org/docs/kotlin-doc.html#block-tags

/**
 * The endpoint data type which describes some HTTP Rest request.
 * It connects to the specific server (host name) and
 * has a specific expected response type.
 *
 * We're not passing the Response type for now
 * because it is better for the Void response case
 * and currently we actually don't do network requests
 * in Kotlin, so, we don't need to decode the http responses
 * and no need to check the http response codes.
 *
 * @property path slash divided string, e.g. `complete/search`
 * @constructor Creates the description for the Http request.
 */
data class Endpoint</* out R : DecodableResponse, */ in S : ServerDescription>(
    val httpMethod: HTTPMethod,
    val path: String,
    val headers: Set<HTTPHeader>?,
    val encodingMethod: ParametersEncodingDestination
) {
    companion object {
        /**
         * Safe init for the immutable Endpoint type to be able to use it
         * on different threads.
         *
         * This method doesn't work on platform level (Swift)
         * for some reason it returns the instance with ServerDescription type
         * instead of the actual generic type which were used.
         *
         * https://helw.net/2020/04/16/multithreading-in-kotlin-multiplatform-apps/
         * */
        fun <SS> frozen(
            httpMethod: HTTPMethod,
            path: String,
            headers: Set<HTTPHeader>?,
            encodingMethod: ParametersEncodingDestination): Endpoint<SS>
        where SS: ServerDescription {
            return Endpoint<SS>(httpMethod, path, headers, encodingMethod).freeze()
        }
    }

    internal fun urlRelatedTo(server: S): Url {
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

    fun request(server: S, requestTimeout: Long, accessToken: String?): HTTPRequestInfo {
        var builder = HttpRequestBuilder()
        builder.method = httpMethod.ktorValue
        builder.timeout {
            this.requestTimeoutMillis = requestTimeout
        }
        val url = urlRelatedTo(server)
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

        val contentTypeHeader = encodingMethod.contentTypeHttpHeader
        builder.headers {
            append(contentTypeHeader.key, contentTypeHeader.value)
        }

        updateWithBody(builder)

        val ktorData = builder.build()
        return HTTPRequestInfo.createFromKtorType(ktorData)
    }

    private fun updateWithBody(builder: HttpRequestBuilder) {
        val readyBodyData = when (encodingMethod) {
            is ParametersEncodingDestination.HttpBody -> encodingMethod.encodedData
            is ParametersEncodingDestination.HttpBodyJSON -> encodingMethod.keyToValue.encode()
            else -> null
        }

        if (readyBodyData == null) {
            return
        }

        val content = ByteArrayContent(readyBodyData, ContentType.Application.Json, null)
        builder.setBody(content)
    }

    private fun urlParameters(): Parameters {
        return when (encodingMethod) {
            is ParametersEncodingDestination.QueryString -> buildParameters(encodingMethod.items)
            else -> Parameters.Empty
        }
    }

    private fun buildParameters(items: Array<URLQueryPair>): Parameters {
        if (items.isEmpty()) return Parameters.Empty
        val parametersBuilder = ParametersBuilder(items.size)
        items.forEach { parametersBuilder.append(it.name, it.value) }
        return parametersBuilder.build()
    }
}

// extensions

internal fun Map<String, Any>.encode(): ByteArray {
    // https://github.com/Kotlin/kotlinx.serialization/issues/746
    val jsonObject = toJsonObject()
    val string = jsonObject.toString()
    return string.toByteArray(Charsets.UTF_8)
}
