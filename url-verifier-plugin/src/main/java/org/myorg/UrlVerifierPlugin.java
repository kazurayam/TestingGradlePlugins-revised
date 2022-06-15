package org.myorg;

import org.gradle.api.Plugin;
import org.gradle.api.Project;
import org.myorg.tasks.UrlVerify;

public class UrlVerifierPlugin implements Plugin<Project> {
    @Override
    public void apply(Project project) {
        // add the 'verification' extension object
        UrlVerifierExtension extension =
                project.getExtensions()
                        .create("verification", UrlVerifierExtension.class);
        // create the 'verifyUrl' task
        project.getTasks().register("verifyUrl", UrlVerify.class, task -> {
            task.getUrl().set(extension.getUrl());
        });
    }
}
