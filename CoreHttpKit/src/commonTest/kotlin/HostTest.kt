import org.cottonweb.CoreHttpKit.DomainName
import org.cottonweb.CoreHttpKit.Host
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class HostTests {
    /**
     * Test data from (not present in official openssl repo for some reason)
     * https://github.com/amiremohamadi/openssl/blob/8a2b8728d01f20e9504b56368b2004417f7bd275/test/x509_internal_test.c#L57
     * */
    val localhostIp = "127.0.0.1"
    val ipadd1 = "1.2.3.4"
    val ipaddr2 = "1.2.3.255"
    val wrongipaddr1 = "1.2.3"
    val wrongipaddr2 = "1.2.3 .4" // with a spac

    val wrongipaddr3 = "example.test" // could be a valid domain
    val ipaddr3 = " 1.2.3.4" // extra space in front
    val ipaddr4 = " 1.2.3.4 " // extra spaces in front and at the end
    val wrongipaddr4 = "1.2.3.4.example.test"

    @Test
    fun testIpAddressHosts() {
        val localhost = Host(localhostIp)
        assertEquals(localhostIp, localhost.rawString)
        assertEquals(Host.Content.IPv4, localhost.content)

        assertFailsWith(
            exceptionClass = Host.Error.NotValidHostInput::class,
            block = { Host(wrongipaddr1) }
        )
    }
}