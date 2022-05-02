import org.cottonweb.CoreHttpKit.ServerDescription

class MockGoogleDnsServer : ServerDescription() {
    override val hostString: String
        get() = domain
    override val domain: String
        get() = "dns.google"
}

class MockGoogleSearchServer : ServerDescription() {
    override val hostString: String
        get() = "www" + "." + domain
    override val domain: String
        get() = "google.com"
}

class MockDuckDuckGoServer : ServerDescription() {
    override val hostString: String
        get() = domain
    override val domain: String
        get() = "ac.duckduckgo.com"
}
