import org.cottonweb.CoreHttpKit.Host
import org.cottonweb.CoreHttpKit.ServerDescription

class MockGoogleDnsServer : ServerDescription(Host("dns.google")) {}

class MockGoogleSearchServer : ServerDescription(Host("www.google.com")) {}

class MockDuckDuckGoServer : ServerDescription(Host("ac.duckduckgo.com")) {}
