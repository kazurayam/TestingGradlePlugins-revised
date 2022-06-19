# Testing Gradle plugins - revised

-   author: kazurayam

-   date: 19 JUNE 2022

## What is this

This article is based on the following article published by the Gradle project:

-   [Testing Gradle plugins](https://docs.gradle.org/current/userguide/testing_gradle_plugins.html)

One day I read the original and found a few points that I can improve. Especially, I wanted an archive of sample codes that works. I struggled for a few days creating it and got a success. So I am going to present the zip file I created attached with my explanation how to test custom Gradle plugins.

## How to use👣

Visit [the top page](https://github.com/kazurayam/TestingGradlePlugins) of this repository, and click on the ![Use this template](https://img.shields.io/badge/-Use%20this%20template-brightgreen). Then you can clone this as template to create your own.

Or you can visit [the Releases page](https://github.com/kazurayam/TestingGradlePlugins-revised/releases/) and download the zip archive. Just download and unzip it.

## The sample project that consumes the custom plugin

![file](../images/file.png) `include-plugin-build/setting.gradle`

    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            substitute(module("org.myorg:url-verifier"))
        }
    }

![file](../images/file.png) `include-plugin-build/build.gradle`

    buildscript {
        dependencies {
            classpath 'org.myorg:url-verifier-plugin'    
        }
    }
    apply plugin: 'org.myorg.url-verifier'    

    verification {
        url = 'https://www.google.com/'    
    }

-   find the custom Plugin by id

-   load the output of the plugin development project into the consumer project’s classpath by `group:name`

-   give value to the plugin parameter

Console interaction

    $ basename `pwd`
    TestingGradlePlugins-revised
    $ cd include-plugin-build/
    $ ./gradlew verifyUrl

    > Task :verifyUrl
    Successfully resolved URL 'https://www.google.com/'

    BUILD SUCCESSFUL in 1s
    5 actionable tasks: 1 executed, 4 up-to-date

## What I revised

[Gradle plugins and Composite builds](https://ncorti.com/blog/gradle-plugins-and-composite-builds) by ncorti
== Image

![umineko 1960x1960](../images/umineko-1960x1960.jpeg)
