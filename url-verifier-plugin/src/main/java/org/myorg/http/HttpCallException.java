package org.myorg.http;

public class HttpCallException extends Exception {

    public HttpCallException(String s, Throwable t) {
        super(s, t);
    }
}
