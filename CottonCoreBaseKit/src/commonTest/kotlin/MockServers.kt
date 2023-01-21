import org.cotton.base.Host
import org.cotton.base.ServerDescription

class MockGoogleDnsServer : ServerDescription(Host("dns.google"))

class MockGoogleSearchServer : ServerDescription(Host("www.google.com"))

class MockDuckDuckGoServer : ServerDescription(Host("ac.duckduckgo.com"))
