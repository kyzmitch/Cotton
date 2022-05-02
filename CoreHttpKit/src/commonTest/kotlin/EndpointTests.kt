import org.cottonweb.CoreHttpKit.Endpoint
import org.cottonweb.CoreHttpKit.HTTPMethod
import org.cottonweb.CoreHttpKit.ParametersEncodingDestination
import org.cottonweb.CoreHttpKit.URLQueryPair
import kotlin.test.Test
import kotlin.test.assertEquals

class EndpointTests {
    val googleDNSserver = MockGoogleDnsServer()
    val googleDnsQueryParams: ArrayList<URLQueryPair>
        get() {
            val params = arrayListOf<URLQueryPair>(
                URLQueryPair("name", "apple.com"),
                URLQueryPair("type", "1"),
                URLQueryPair("cd", "false"),
                URLQueryPair("ct", ""),
                URLQueryPair("do", "false"),
                URLQueryPair("edns_client_subnet", "0.0.0.0/0"),
                URLQueryPair("random_padding", "")
            )
            return params
        }

    val googleDNSendpoint: Endpoint<MockGoogleDnsServer>
        get() {
            val endpoint: Endpoint<MockGoogleDnsServer> = Endpoint(
                HTTPMethod.GET,
                "resolve",
                null,
                ParametersEncodingDestination.QueryString(googleDnsQueryParams.toTypedArray())
            )
            return endpoint
        }

    val expectedGoogleDnsUrlStr = "https://dns.google:443/resolve?name=apple.com&type=1&cd=false&do=false&edns_client_subnet=0.0.0.0/0"

    @Test
    fun testURL() {
        val dnsAccessToken1 = "xzr-564"
        val dnsRequest = googleDNSendpoint.request(googleDNSserver, 60, dnsAccessToken1)
        assertEquals(expectedGoogleDnsUrlStr, dnsRequest.rawURL)
    }
}
