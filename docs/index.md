-   [Testing Gradle plugins - revised](#testing-gradle-plugins-revised)
    -   [Prerequisites](#prerequisites)
    -   [How to use👣](#how-to-use)
    -   [Directory structure](#directory-structure)
        -   [Composite build](#composite-build)
    -   [The sample Gradle project that consumes custom plugin](#the-sample-gradle-project-that-consumes-custom-plugin)
    -   [What I revised](#what-i-revised)
    -   [Image](#image)

# Testing Gradle plugins - revised

-   author: kazurayam

-   date: 19 JUNE 2022

## Prerequisites

1.  It is assumed that you have Java8 or newer installed

2.  I tested these projects using Gradle v7.4.2

## How to use👣

Visit [the top page](https://github.com/kazurayam/TestingGradlePlugins) of this repository, and click on the ![Use this template](https://img.shields.io/badge/-Use%20this%20template-brightgreen). Then you can clone this as template to create your own.

Or you can visit [the Releases page](https://github.com/kazurayam/TestingGradlePlugins-revised/releases/) and download the latest "Source code" archive. Just download and un-archive it.

## Directory structure

This repository contains the root directory `TestingGradlePlugins-revised` which contains 2 Gradle projects: `url-verifier-plugin` and `include-plugin-build`.

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

The `include-plugin-build` project consumes the custom Gradle plugin which is developed in the `url-veirifer-plugin` project.

### Composite build

There is a Gradle term *Composite builds*. The `include-plugin-build` project is a concrete example of "Composite builds", and it is working --- I am happy about it.

By Googling you can find several resources to learn what *Composite build* is, how to make it, how to utilize it. I had a look at these resources, but I must confess that I do not understand *Composite builds* yet. It requires you to be a Gradle expert, which certainly I am not yet.

## The sample Gradle project that consumes custom plugin

![file](./images/file.png) `include-plugin-build/setting.gradle`

    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            substitute(module("org.myorg:url-verifier"))
        }
    }

![file](./images/file.png) `include-plugin-build/build.gradle`

    buildscript {
        // load the output of the plugin development project
        // into this consumer project
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

## What I revised

[Gradle plugins and Composite builds](https://ncorti.com/blog/gradle-plugins-and-composite-builds) by ncorti

## Image

![umineko 1960x1960](./images/umineko-1960x1960.jpeg)
