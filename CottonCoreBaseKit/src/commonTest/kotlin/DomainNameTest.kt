import org.cotton.base.DomainName
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

fun Char.repeat(count: Int): String = this.toString().repeat(count)

class DomainNameTests {
    val egyptian: String = "\u0644\u064A\u0647\u0645\u0627\u0628\u062A\u0643\u0644\u0645\u0648\u0634\u0639\u0631\u0628\u064A\u061F"
    val egyptianCode: String = "egbpdaj6bu4bxfgehfvwxn"
    val hebrew: String = "\u05DC\u05DE\u05D4\u05D4\u05DD\u05E4\u05E9\u05D5\u05D8\u05DC\u05D0\u05DE\u05D3\u05D1\u05E8\u05D9\u05DD\u05E2\u05D1\u05E8\u05D9\u05EA"
    val hebrewCode: String = "4dbcagdahymbxekheh6e0a7fei0b"
    val russian: String = "\u043F\u043E\u0447\u0435\u043C\u0443\u0436\u0435\u043E\u043D\u0438\u043D\u0435\u0433\u043E\u0432\u043E\u0440\u044F\u0442\u043F\u043E\u0440\u0443\u0441\u0441\u043A\u0438"
    val russianCode: String = "b1abfaaepdrnnbgefbadotcwatmq2g4l"
    val example = "example.com"
    val wrongIPv4Addres1 = "1.2.3"

    @Test
    fun testUnicodeToPunycode() {
        val egyptianDomainName = DomainName(egyptian)
        assertEquals(egyptianCode, egyptianDomainName.rawString)
        val hebrewDomainName = DomainName(hebrew)
        assertEquals(hebrewCode, hebrewDomainName.rawString)
        val russianDomainName = DomainName(russian)
        assertEquals(russianCode, russianDomainName.rawString)
        val domainName1 = DomainName(example)
        assertEquals(example, domainName1.rawString)
    }

    @Test
    fun testWrongInputs() {
        // https://www.baeldung.com/kotlin/assertfailswith#using-kotlins-assertfailswith-method
        assertFailsWith<DomainName.Error.EmptyString>(
            message = "Domain name can't be constructed from the empty string",
            block = { DomainName("") }
        )

        assertFailsWith(
            exceptionClass = DomainName.Error.DotAtBeginning::class,
            block = { DomainName(".example.com") }
        )

        assertFailsWith(
            exceptionClass = DomainName.Error.DoubleDots::class,
            block = { DomainName("example..com") }
        )

        val tooLongLength = 254
        var tooLongInputForDomainName = 'a'.repeat(tooLongLength)
        val exception = assertFailsWith<DomainName.Error.WrongLength>(
            block = { DomainName(tooLongInputForDomainName) }
        )
        assertEquals(tooLongLength, exception.inputLength)

        assertFailsWith(
            exceptionClass = DomainName.Error.RightmostDomainLabelStartsWithDigit::class,
            block = { DomainName(wrongIPv4Addres1) }
        )
    }

    @Test
    fun testTopSites() {
        val opennetCode: String = "opennet.ru"
        val opennet = DomainName("opennet.ru")
        assertEquals(opennetCode, opennet.rawString)
    }
}
