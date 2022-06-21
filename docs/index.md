# Testing Gradle plugins - revised

-   author: kazurayam

-   date: 19 JUNE 2022

## Introduction

This article introduces you how to perform automated-tests for your custom Gradle plugins.

## How to use👣

### Prerequisites

1.  It is assumed that you have Java8 or newer installed

2.  I tested these projects using Gradle v7.4.2

### How to get the sample project

Visit [the top page](https://github.com/kazurayam/TestingGradlePlugins) of this repository, and click on the ![Use this template](https://img.shields.io/badge/-Use%20this%20template-brightgreen). Then you can clone this as template to create your own.

Or you can visit [the Releases page](https://github.com/kazurayam/TestingGradlePlugins-revised/releases/) and download the latest "Source code" archive. Just download and un-archive it.

### How to run the automated tests

You can perform automated-test for the sample custom plugin; do like this:

![console](./images/console.png)

    $ basename $(pwd)
    TestingGradlePlugins-revised
    $ cd url-verifier-plugin
    $ ./gradlew clean check

    BUILD SUCCESSFUL in 22s
    12 actionable tasks: 12 executed

    $ cd ../include-plugin-build
    $ ./gradlew verifyUrl

    > Task :verifyUrl
    Successfully resolved URL 'https://www.google.com/'

    BUILD SUCCESSFUL in 1s
    5 actionable tasks: 2 executed, 3 up-to-date

The `:verifyUrl` task, which is defined in the `include-plugin-build/build.gradle` file, runs a custom Gradle plugin `org.myorg.url-verifier` developed by the `url-verify-plugin` project and asserts the plugin’s outcomes.
== Directory structure

This repository contains a root directory `TestingGradlePlugins-revised` which contains 2 Gradle projects: `url-verifier-plugin` and `include-plugin-build`.

![console](./images/console.png)

    $ basename `pwd`
    TestingGradlePlugins-revised
    $ tree . -L 2
    .
    ├── README.md
    ├── include-plugin-build
    │   ├── build.gradle
    │   ├── gradle
    │   ├── gradlew
    │   ├── gradlew.bat
    │   └── settings.gradle
    └── url-verifier-plugin
        ├── build.gradle
        ├── gradle
        ├── gradlew
        ├── gradlew.bat
        ├── settings.gradle
        └── src

The root directory `TestingGradlePlugins-revised` is mapped to the Git repository at <https://github.com/kazurayam/TestingGradlePlugins-revised>. Therefore I can keep these 2 Gradle projects version-controlled by Git in sync.

The `url-verifier-plugin` project develops a custom Gradle plugin. The `url-verifier-plugin` project is self-contained, is independent on the `include-plugin-build` project at all.

The `include-plugin-build` project consumes the custom Gradle plugin which is developed by the `url-veirifer-plugin` project.

### Gradle’s terminology "Composite build"

There is a Gradle term *Composite builds*. The `include-plugin-build` project is a concrete example of "Composite builds", and it is working fine --- I am happy about it.

By Googling you can find several resources to learn what *Composite build* is, how to make it, how to utilize it. I had a look at these resources. For example:

-   <https://docs.gradle.org/current/userguide/composite_builds.html>

But I must confess that I do not understand *Composite builds* . It requires you to be a Gradle expert, which certainly I am not yet.

## The sample Gradle project that consumes custom plugin

Let’s have a look at the code in the consumer project `include-plugin-build`. It has only 2 files.

![file](./images/file.png) `include-plugin-build/setting.gradle`

    // include the build of the plugin development project
    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            // explicitly load the output of the included build
            // into the consumer project's classpath
            substitute(module("org.myorg:url-verifier"))
        }
    }

![file](./images/file.png) `include-plugin-build/build.gradle`

    buildscript {
        // declare the output of the plugin development project
        // as a dependency of this consumer project
        dependencies {
            classpath 'org.myorg:url-verifier-plugin'
            // `<group>:<name>` without `<version>`
        }
    }

    // find the custom plugin by id
    apply plugin: 'org.myorg.url-verifier'

    verification {
        // give a value to the custom plugin's parameter
        url = 'https://www.google.com/'
    }

The following Console interaction demonstrates how to run a task `verifyUrl` which calls the custom plugin `org.myorg.url-verifier` :

![console](./images/console.png)

    $ basename `pwd`
    TestingGradlePlugins-revised
    $ cd include-plugin-build/
    $ ./gradlew verifyUrl

    > Task :verifyUrl
    Successfully resolved URL 'https://www.google.com/'

    BUILD SUCCESSFUL in 1s
    5 actionable tasks: 1 executed, 4 up-to-date

## Setting up automated tests

### Organizing directories for source

The plugin development project is named `url-verifier-plugin`. It has 4 sub-directories: `src/main/java`, `src/test/groovy`, `src/integrationTest/groovy` and `src/functionalTest/groovy`. These directories form 4 source sets.

![console](./images/console.png)

    $ basename $(pwd)
    url-verifier-plugin
    $ tree . -L 3
    .
    └── src
        ├── functionalTest
        │   └── groovy
        ├── integrationTest
        │   └── groovy
        ├── main
        │   ├── java
        │   └── resources
        └── test
            └── groovy

The `src/main/` contains the source of our custom plugin, written in Java.

We have 3 distinguished directories for automated tests.

The `src/test/` contains the unit-tests against the code in the `src/main/java`.

The `src/integrationTest/` contains the integration tests against the classes/methods in the `src/main/java` involving access to external resources such as web resources connected as `http://` or DB.

The `src/functionalTest/` contains the functional tests against the custom plugin developed in the `src/main/`. It generates a temporary `build.gradle` file which uses the target custom plugin. The functional tests execute the temporary `build.gradle` immediately and check how the plugin works.

### Configuring source sets and tasks

Gradle’s "Source sets" gives us a powerful way to structure source code in our Gradle projects. You can learn more about Source sets at ["Gradle Source Sets", Baeldung](https://www.baeldung.com/gradle-source-sets)

The `url-verifier-plugin` project uses the `groovy` plugin and `java-gradle-plugin`.

![url-verifier-plugin/build.gradle](./images/file.png)

    plugins {
        id 'groovy'
        id 'java-gradle-plugin'

The `groovy` plugin implicitly creates 2 Source sets: `main` and `test`.

The `main` source set is configured to point the `url-verifier-plugin/src/main/` directory for source codes, which would include the plugin class and its various associated classes.

The `test` source set is configured to point the `url-verifier-plugin/src/test/` directory for source codes, which would include classes that perform unit-tests over the classes in the `main` source set.

Now we want to create 2 more source sets: `integrationTest` and `functionalTest`. The following fragment create these 2 source sets, and add custom tasks named `integrationTest` and `functionalTest`.

![url-verifyer-plugin/build.gradle](./images/file.png)

    def integrationTest = sourceSets.create("integrationTest")
    def integrationTestTask = tasks.register("integrationTest", Test) {
        description = "Runs the integration tests."
        testClassesDirs = integrationTest.output.classesDirs
        classpath = integrationTest.runtimeClasspath
        mustRunAfter(tasks.named('test'))
    }

    def functionalTest = sourceSets.create("functionalTest")
    def functionalTestTask = tasks.register("functionalTest", Test) {
        description = "Runs the functional tests."
        group = "verification"
        testClassesDirs = functionalTest.output.classesDirs
        classpath = functionalTest.runtimeClasspath
        mustRunAfter(tasks.named('test'))
    }

## What I revised

[Gradle plugins and Composite builds](https://ncorti.com/blog/gradle-plugins-and-composite-builds) by ncorti

## Image

![umineko 1960x1960](./images/umineko-1960x1960.jpeg)
