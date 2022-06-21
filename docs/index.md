-   [Testing Gradle plugins - revised](#testing-gradle-plugins-revised)
    -   [Introduction](#introduction)
    -   [How to use👣](#how-to-use)
        -   [Prerequisites](#prerequisites)
        -   [How to get the sample project](#how-to-get-the-sample-project)
        -   [How to run the automated tests](#how-to-run-the-automated-tests)
    -   [Directory structure](#directory-structure)
        -   [Gradle’s terminology "Composite build"](#gradles-terminology-composite-build)
    -   [Setting up automated tests](#setting-up-automated-tests)
        -   [Organizing directories for sources](#organizing-directories-for-sources)
        -   [Configuring source sets and tasks](#configuring-source-sets-and-tasks)
        -   [Configuring `java-gradle-plugin`](#configuring-java-gradle-plugin)
    -   [Sample Gradle project that consumes custom plugin](#sample-gradle-project-that-consumes-custom-plugin)
    -   [What I revised](#what-i-revised)
    -   [Image](#image)

# Testing Gradle plugins - revised

-   author: kazurayam

-   date: 19 JUNE 2022

## Introduction

This article provides a runnable sample code set that shows you how to perform automated-tests for a custom Gradle plugins.

This article is based on an article published by Gradle project:

-   [Testing Gradle Plugin](https://docs.gradle.org/current/userguide/testing_gradle_plugins.html)

## How to use👣

### Prerequisites

1.  It is assumed that you have Java8 or newer installed

2.  I tested the artifacts using Gradle v7.4.2 on macOS v12.4

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

When you run the `:check` task, other tasks `:test`, `:intergrationTest` and `:functionalTest` will effectively executed. These 3 tasks implements automated tests for the sample custom Gradle plugin `org.myorg.url-verifier`.

And one more scenario.

![console](./images/console.png)

    $ cd ../include-plugin-build
    $ ./gradlew verifyUrl

    > Task :verifyUrl
    Successfully resolved URL 'https://www.google.com/'

    BUILD SUCCESSFUL in 1s
    5 actionable tasks: 2 executed, 3 up-to-date

The `:verifyUrl` task, which is defined in the `include-plugin-build/build.gradle` file, runs a custom Gradle plugin `org.myorg.url-verifier` developed by the `url-verify-plugin` project and asserts the plugin’s outcomes.

## Directory structure

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

But I must confess that I do not really understand *Composite builds* yet.

## Setting up automated tests

### Organizing directories for sources

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

![file](./images/file.png) `url-verifier-plugin/build.gradle`

    plugins {
        id 'groovy'
        id 'java-gradle-plugin'

The `groovy` plugin implicitly creates 2 Source sets: `main` and `test`.

The `main` source set is configured to point the `url-verifier-plugin/src/main/` directory for source codes, which would include the plugin class and its various associated classes.

The `test` source set is configured to point the `url-verifier-plugin/src/test/` directory for source codes, which would include classes that perform unit-tests over the classes in the `main` source set.

Now we want to create 2 more source sets: `integrationTest` and `functionalTest`. The following fragment create these 2 source sets, and add custom tasks named `integrationTest` and `functionalTest`.

![file](./images/file.png) `url-verifyer-plugin/build.gradle`

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

    tasks.named('check') {
        dependsOn(integrationTestTask, functionalTestTask)
    }

By the above code fragment 2 tasks are created: `:integrationTest` task and `:functionalTest` task.

One more task is declared: `:check` task, which depends on the `:integrationTest` task and the `:functionalTest` task.

### Configuring `java-gradle-plugin`

The functional test
[`UrlVerifierPluginFunctionalTest`](https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/functionalTest/groovy/org/myorg/UrlVerifierPluginFunctionalTest.groovy)
wants to execute the custom plugin using
[`org.gradle.testkit.runner.GradleRunner`](https://docs.gradle.org/current/javadoc/org/gradle/testkit/runner/GradleRunner.html)
class. The
[`java-gradle-plugin`](https://docs.gradle.org/current/userguide/java_gradle_plugin.html)
can bring the GradleRunner accessible for the functional test. A single line of configuration is required for that.

![file](./images/file.png) `url-verifier-plugin/build.gradle`

    gradlePlugin {
        // configure the `java-gradle-plugin` so that it looks at the `sourceSets.functionalTest`
        // to find the tests for the custom plugin.
        testSourceSets(sourceSets.functionalTest)
        // This makes `org.gradle.testkit.runner.GradleRunner` class available to the
        // functionalTest classes.
    }

## Sample Gradle project that consumes custom plugin

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

Let’s have a look at the code in the consumer project `include-plugin-build`. It has only 2 files.

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

The `buildscript {}` closure here declares that this build script depends on the class library `org.myorg:url-verifier-plugin`. And the `apply plugin` imports the custom Gradle plugin of id `org.myorg.url-verifier`. The `verifycation { url = '…​''` closure is specifying the value for the `url` parameter of the plugin’s implementing class.

![file](./images/file.png) `include-plugin-build/setting.gradle`

    // include the build of the plugin development project
    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            // explicitly load the output of the included build
            // into the consumer project's classpath
            substitute(module("org.myorg:url-verifier"))
        }
    }

I must confess, I do not understand the terms here: `includeBuild`, `dependencySubstitution`, `substitute` and `module`. I learned them in another article ["Gradle Plugins and CompositeBuilds" by Nicola Corti](https://ncorti.com/blog/gradle-plugins-and-composite-builds). I copy&pasted it and tried. It happened to work.

## What I revised

[Gradle plugins and Composite builds](https://ncorti.com/blog/gradle-plugins-and-composite-builds) by ncorti

## Image

![umineko 1960x1960](./images/umineko-1960x1960.jpeg)
