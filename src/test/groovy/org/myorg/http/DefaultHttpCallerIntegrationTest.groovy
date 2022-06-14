package org.myorg.http

import spock.lang.Specification
import spock.lang.Subject

/**
 * https://docs.gradle.org/current/userguide/testing_gradle_plugins.html
 */
class DefaultHttpCallerIntegrationTest extends Specification {

    @Subject HttpCaller httpCaller = new DefaultHttpCaller()

    def "can make successful HTTP GET call"() {
        when:
        def httpResponse = httpCaller.get("https://www.google.com/")

        then:
        httpResponse.code == 200
        httpResponse.message == 'OK'
    }

    def "throws exception when calling unknown host via HTTP GET"() {
        String url = 'https://www.wedonotknowyou123.com/'

        when:
        httpCaller.get(url)

        then:
        def t = thrown(HttpCallException)
        t.message == "Failed to call URL '${url}' via HTTP GET"
        t.cause instanceof UnknownHostException
    }
}
