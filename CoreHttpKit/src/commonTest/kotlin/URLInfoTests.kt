import org.cottonweb.CoreHttpKit.DomainName
import org.cottonweb.CoreHttpKit.HttpScheme
import org.cottonweb.CoreHttpKit.URLInfo
import kotlin.test.Test
import kotlin.test.assertEquals

class URLInfoTests {
    val httpsScheme = HttpScheme.https
    val urlLastPartGoogleDns = "resolve?name=apple.com&type=1&cd=false&do=false&edns_client_subnet=0.0.0.0%2F0"
    val initialGoogleDnsUrlStr = "https://dns.google:443/" + urlLastPartGoogleDns
    val withIpAddressGoogleDnsUrlStr = "https://127.0.0.1:443/" + urlLastPartGoogleDns

    @Test
    fun testOriginalURL() {
        val googleDNStr = "dns.google"
        val googleDN = DomainName(googleDNStr)
        assertEquals(googleDNStr, googleDN.rawString)
        val googleDsnIpInfo = URLInfo(httpsScheme, urlLastPartGoogleDns, googleDN)
        assertEquals(initialGoogleDnsUrlStr, googleDsnIpInfo.url)
        // should return the original URL if ip address is null
        assertEquals(initialGoogleDnsUrlStr, googleDsnIpInfo.urlWithIPaddress())
        val googleDNip = "127.0.0.1"
        val updatedGoogleDsnIpInfo = googleDsnIpInfo.withIPAddress(googleDNip)
        assertEquals(withIpAddressGoogleDnsUrlStr, updatedGoogleDsnIpInfo.urlWithIPaddress())
    }
}