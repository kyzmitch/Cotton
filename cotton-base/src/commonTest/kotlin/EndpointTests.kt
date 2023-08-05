import org.cotton.base.ContentTypeValue
import org.cotton.base.Endpoint
import org.cotton.base.HTTPHeader
import org.cotton.base.HTTPHeader.Accept
import org.cotton.base.HTTPHeader.ContentType
import org.cotton.base.HTTPMethod
import org.cotton.base.ParametersEncodingDestination
import org.cotton.base.URLQueryPair
import kotlin.test.Test
import kotlin.test.assertEquals

class EndpointTests {
    val googleDNSserver = MockGoogleDnsServer()
    val duckduckgoServer = MockDuckDuckGoServer()
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

    val ddGoQueryParams: ArrayList<URLQueryPair>
        get() {
            val params = arrayListOf<URLQueryPair>(
                URLQueryPair("q", "kotlin swift"),
                URLQueryPair("type", "list")
            )
            return params
        }

    val searchHeaders: Set<HTTPHeader>
        get() {
            return setOf<HTTPHeader>(
                HTTPHeader.Accept(ContentTypeValue.JsonSuggestions),
                HTTPHeader.ContentType(ContentTypeValue.JsonSuggestions),
            )
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

    val ddgoEndpoint: Endpoint<MockDuckDuckGoServer>
        get() {
            val endpoint: Endpoint<MockDuckDuckGoServer> = Endpoint(
                HTTPMethod.GET,
                "ac",
                searchHeaders,
                ParametersEncodingDestination.QueryString(ddGoQueryParams.toTypedArray())
            )
            return endpoint
        }

    val expectedGoogleDnsUrlStr = "https://dns.google:443/resolve?name=apple.com&type=1&cd=false&do=false&edns_client_subnet=0.0.0.0%2F0"
    val expectedDDGoAutoCompleteUrlStr = "https://ac.duckduckgo.com:443/ac?q=kotlin%20swift&type=list"

    @Test
    fun testURL() {
        val dnsRequest = googleDNSendpoint.request(googleDNSserver, 60, null)
        assertEquals(expectedGoogleDnsUrlStr, dnsRequest.rawURL)
    }

    @Test
    fun testSpaceInQueryParamValue() {
        // also known as percent encoding
        val autoCompleteRequest = ddgoEndpoint.request(duckduckgoServer, 60, null)
        assertEquals(expectedDDGoAutoCompleteUrlStr, autoCompleteRequest.rawURL)
    }
}
