package org.cottonweb.CoreHttpKit

import kotlin.native.concurrent.freeze

object Freezer {
    fun <S: ServerDescription> frozenEndpoint(endpoint: Endpoint<S>) = endpoint.freeze()
}