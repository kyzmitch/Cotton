package org.cottonweb.CoreHttpKit
import io.ktor.http.*

/// Would be good if this interface is based on some Decodable interface
interface ResponseType {
    val successCodes: IntArray
        get() = intArrayOf(200, 201)
}

data class Endpoint<out R: ResponseType, in S: Server>(val method: HTTPMethod,
                                                        val path: String,
                                                        val headers: Set<HTTPHeader>?) {
    fun urlRelatedTo(server: S): Url {
        val scheme = server.scheme
        val urlProtocol = URLProtocol(scheme.stringValue, scheme.port)
        val pathSegments: List<String> = mutableListOf("")
        val parameters: Parameters = Parameters.Empty
        // https://github.com/ktorio/ktor/blob/main/ktor-http/common/src/io/ktor/http/URLBuilder.kt
        val builder = URLBuilder(urlProtocol,
            server.hostString,
            scheme.port,
            null,
            null,
            pathSegments,
            parameters)
        return builder.build()
    }
}
