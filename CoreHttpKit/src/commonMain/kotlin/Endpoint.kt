package org.cottonweb.CoreHttpKit

/// Would be good if this interface is based on some Decodable interface
public interface ResponseType {
    val successCodes: IntArray
        get() = intArrayOf(200, 201)
}

public class Endpoint<out R: ResponseType, out S: Server>(method: HTTPMethod, path: String, headers: Set<HTTPHeader>?) {
    val method: HTTPMethod = method
    val path: String = path
    val headers: Set<HTTPHeader>? = headers
}
