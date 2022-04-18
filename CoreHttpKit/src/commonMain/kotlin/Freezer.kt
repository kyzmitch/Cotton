package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

object Freezer {
    fun frozenEndpoint(endpoint: Endpoint) = endpoint.freeze()
}