import org.cottonweb.CoreHttpKit.withoutLeadingTrailingSpaces
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class TextExtensionsTest {
    @Test
    fun testStringsWithSpaces() {
        val localhostIp = "127.0.0.1"
        assertEquals(localhostIp, localhostIp.withoutLeadingTrailingSpaces)
        val localhostIpWithSpaces1 = " 127.0.0.1 "
        assertEquals("127.0.0.1", localhostIpWithSpaces1.withoutLeadingTrailingSpaces)
        val localhostIpWithMultiSpaces = "  127.0.0.1     "
        assertEquals("127.0.0.1", localhostIpWithMultiSpaces.withoutLeadingTrailingSpaces)
        val middleSpace = "1.2.3 .4"
        assertNotEquals("1.2.3.4", middleSpace.withoutLeadingTrailingSpaces)
        val frontSpace = " 1.2.3.4"
        assertEquals("1.2.3.4", frontSpace.withoutLeadingTrailingSpaces)
    }
}