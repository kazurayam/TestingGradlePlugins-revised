# Testing Gradle plugins - revised

-   author: kazurayam

-   date: 19 JUNE 2022

## Prerequisites

1.  It is assumed that you have Java8 or newer installed

2.  I tested these projects using Gradle v7.4.2

## How to use👣

Visit [the top page](https://github.com/kazurayam/TestingGradlePlugins) of this repository, and click on the ![Use this template](https://img.shields.io/badge/-Use%20this%20template-brightgreen). Then you can clone this as template to create your own.

Or you can visit [the Releases page](https://github.com/kazurayam/TestingGradlePlugins-revised/releases/) and download the latest "Source code" archive. Just download and unzip it.

## Composite build structure

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

## The sample project that consumes the custom plugin

![file](./images/file.png) `include-plugin-build/setting.gradle`

    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            substitute(module("org.myorg:url-verifier"))
        }
    }

![file](./images/file.png) `include-plugin-build/build.gradle`

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

![console](./images/console.png) Console interaction

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
