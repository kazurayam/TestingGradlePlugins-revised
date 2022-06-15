package org.myorg.tasks;

import org.gradle.api.DefaultTask;
import org.gradle.api.provider.Property;
import org.gradle.api.tasks.Input;
import org.gradle.api.tasks.Optional;
import org.gradle.api.tasks.TaskAction;
import org.myorg.http.DefaultHttpCaller;
import org.myorg.http.HttpCallException;
import org.myorg.http.HttpCaller;
import org.myorg.http.HttpResponse;

abstract public class UrlVerify extends DefaultTask {

    @Input
    abstract public Property<String> getUrl();

    public UrlVerify() {
        getUrl().convention("https://docs.gradle.org/current/userguide/testing_gradle_plugins.html");
    }
    @TaskAction
    public void action() throws HttpCallException {
        HttpCaller httpCaller = new DefaultHttpCaller();
        HttpResponse httpResponse = httpCaller.get(this.getUrl().get());
        if (httpResponse.getCode() == 200) {
            System.out.println("Successfully resolved URL '${getUrl().get()}'");
        } else {
            System.err.println("Failed to resolve URL '${getUrl().get()}'");
        }
    }
}
