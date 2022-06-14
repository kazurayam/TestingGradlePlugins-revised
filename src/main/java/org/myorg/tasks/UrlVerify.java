package org.myorg.tasks;

import org.gradle.api.DefaultTask;
import org.gradle.api.provider.Property;
import org.gradle.api.tasks.Input;
import org.gradle.api.tasks.TaskAction;

abstract public class UrlVerify extends DefaultTask {

    @Input
    abstract public Property<String> getUrl();

    @TaskAction
    public void action() {
        System.out.println("url = ${getUrl().get()}");
    }
}
