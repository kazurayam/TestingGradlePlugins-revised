-   [カスタムGradleプラグインを自動化テストする方法](#カスタムgradleプラグインを自動化テストする方法)
    -   [はじめに](#はじめに)
    -   [使い方](#使い方)
        -   [前提していること](#前提していること)
        -   [サンプルコードをどうやって手に入れるか](#サンプルコードをどうやって手に入れるか)
        -   [自動化テストをどうやって実行するか](#自動化テストをどうやって実行するか)
    -   [ディレクトリ構造](#ディレクトリ構造)
        -   [GradleのComposite buildというもの](#gradleのcomposite-buildというもの)
    -   [カスタムGradleプラグインを書く](#カスタムgradleプラグインを書く)
        -   [org.myorg.UrlVerifierPlugin class](#org-myorg-urlverifierplugin-class)
        -   [org.myorg.UrlVerifierExtension class](#org-myorg-urlverifierextension-class)
        -   [org.myorg.tasks.UrlVerify class](#org-myorg-tasks-urlverify-class)
        -   [org.myorg.http.DefaultHttpCaller class](#org-myorg-http-defaulthttpcaller-class)
        -   [org.myorg.http.HttpCaller class](#org-myorg-http-httpcaller-class)
        -   [org.myorg.http.HttpResponse class](#org-myorg-http-httpresponse-class)
    -   [自動化されたテスト](#自動化されたテスト)
        -   [テストのソースのディレクトリ構造](#テストのソースのディレクトリ構造)
        -   [Configuring source sets and tasks](#configuring-source-sets-and-tasks)
        -   [Configuring `java-gradle-plugin`](#configuring-java-gradle-plugin)
        -   [Configuring Testing Framework "Spock"](#configuring-testing-framework-spock)
        -   [Code for Unit test](#code-for-unit-test)
        -   [Code for Integration test](#code-for-integration-test)
        -   [Code for Functional test](#code-for-functional-test)
    -   [Sample Gradle project that consumes custom plugin](#sample-gradle-project-that-consumes-custom-plugin)
    -   [How I revised the original](#how-i-revised-the-original)
        -   [How to construct Composite projects](#how-to-construct-composite-projects)
        -   [Why not doing publishToMavenLocal?](#why-not-doing-publishtomavenlocal)
        -   [integrationTest depends on classes in the main source set](#integrationtest-depends-on-classes-in-the-main-source-set)
        -   [Added java codes as example](#added-java-codes-as-example)

# カスタムGradleプラグインを自動化テストする方法

-   著者: kazurayam

-   日付: 2022年6月

## はじめに

カスタムなGradleプラグインを開発しようというとき、どうやって自動化テストすることができるか。その方法を説明します。ちゃんと動くサンプルコード一式を提供します。

Gradle本家プロジェクトによるこの記事に基づいています。

-   [Testing Gradle Plugin](https://docs.gradle.org/current/userguide/testing_gradle_plugins.html)

## 使い方

### 前提していること

1.  あなたの環境にJava8ないしそれ以降のJava環境がインストール済みであること

2.  macOS v12.4でGradle v7.4.2を使ってこの記事をテストしました。WindowsやLinuxでも問題なく動くはずですが、わたしは試していません。

3.  あなたがJavaプログラミングとGradleの基本を理解していることを前提します。 `$ ./gradlw test` というコマンドが何をしているかというレベルの説明は省きます。

### サンプルコードをどうやって手に入れるか

あなたがGitHubアカウントを持っているならば、このGitHubレポジトリのトップ [the top page](https://github.com/kazurayam/TestingGradlePlugins-revised) を開き、![Use this template](https://img.shields.io/badge/-Use%20this%20template-brightgreen) をクリックしましょう。あなたのGitHubアカウントの中に新しいレポジトリとして本レポジトリの複製を作ることができます。

あなたがGitHubアカウントを持っていないならば、 [Releasesページ](https://github.com/kazurayam/TestingGradlePlugins-revised/releases/) を開き、最新の"Source code" のzipをダウンロードしてください。

### 自動化テストをどうやって実行するか

サンプルとして提供された自動化テストを走らせるにはコマンドラインで下記のように操作します。

![console](./images/console.png)

    $ basename $(pwd)
    TestingGradlePlugins-revised
    $ cd url-verifier-plugin
    $ ./gradlew clean check
    Starting a Gradle Daemon (subsequent builds will be faster)
    Type-safe dependency accessors is an incubating feature.
    > Task :clean UP-TO-DATE
    > Task :compileJava
    > Task :compileGroovy NO-SOURCE
    > Task :pluginDescriptors
    > Task :processResources
    > Task :classes
    > Task :compileTestJava NO-SOURCE
    > Task :compileTestGroovy
    > Task :processTestResources NO-SOURCE
    > Task :testClasses
    > Task :test
    > Task :compileFunctionalTestJava NO-SOURCE
    > Task :compileFunctionalTestGroovy
    > Task :processFunctionalTestResources NO-SOURCE
    > Task :functionalTestClasses
    > Task :pluginUnderTestMetadata
    > Task :functionalTest
    > Task :compileIntegrationTestJava NO-SOURCE
    > Task :compileIntegrationTestGroovy
    > Task :processIntegrationTestResources NO-SOURCE
    > Task :integrationTestClasses
    > Task :integrationTest
    > Task :validatePlugins
    > Task :check

    BUILD SUCCESSFUL in 32s
    12 actionable tasks: 11 executed, 1 up-to-date

`:url-verifier-plugin:check` タスクを実行するとそれを基点として\`:url-verifier-plugin:test\`タスクと `:url-verifier-plugin:intergrationTest` タスクと `:url-verifier-plugin:functionalTest` が実行されます。これら3つのタスクがカスタムGradleプラグイン `org.myorg.url-verifier` のための自動化テストです.

もうひとつ、テストのやり方の例があります。

![console](./images/console.png)

    $ cd ../include-plugin-build
    $ ./gradlew verifyUrl
    > Task :url-verifier-plugin:compileJava UP-TO-DATE
    > Task :url-verifier-plugin:compileGroovy NO-SOURCE
    > Task :url-verifier-plugin:pluginDescriptors UP-TO-DATE
    > Task :url-verifier-plugin:processResources UP-TO-DATE
    > Task :url-verifier-plugin:classes UP-TO-DATE
    > Task :url-verifier-plugin:jar

    > Task :verifyUrl
    Successfully resolved URL 'https://www.google.com/'

    BUILD SUCCESSFUL in 2s
    5 actionable tasks: 2 executed, 3 up-to-date

The `:invlude-plugin-build` プロジェクトの `:verifyUrl` タスクは `url-verify-plugin` プロジェクトで開発された カスタムGradleプラグイン `org.myorg.url-verifier` を実行して、その結果を検証します。

## ディレクトリ構造

このレポジトリには根ディレクトリとして `TestingGradlePlugins-revised` ディレクトリがあります。その下にディレクトリが二つ（`url-verifier-plugin` と `include-plugin-build`）あって、各々が独立したGradleプロジェクトになっています。.

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

ディレクトリ `TestingGradlePlugins-revised` がGitレポジトリのルートであり、GitHubレポジトリ　<https://github.com/kazurayam/TestingGradlePlugins-revised> に格納されていて、その下にある２つのGradleプロジェクトを同期を保ったままバージョン管理することができています。

第一のGradleプロジェクト `url-verifier-plugin` でカスタムGradleプラグインを開発します。 `url-verifier-plugin` プロジェクトは自己完結的であって、隣の `include-plugin-build` プロジェクトにはまったくつながりがありません。

第二のGradleプロジェクト `include-plugin-build` は隣の\`url-veirifer-plugin\` プロジェクトで開発されたカスタムGradleプラグインを呼び出して実行します。

### GradleのComposite buildというもの

Gradleには *Composite builds* という用語がある。 `include-plugin-build` プロジェクトは *Composite builds* の具体例になっています。ちゃんと動く。

Google検索すれば *Composite build* とは何か、どうやって作るのか、何に役立つのか、といったことを解説する記事がいくつも見つかります。たとえば

-   <https://docs.gradle.org/current/userguide/composite_builds.html>

しかしComposite buildsを理解するにはGradleに関する詳細な知識が必要で、正直なところ、わたしはまだ *Gradle Composite builds* がよくわかっていません。

## カスタムGradleプラグインを書く

\`url-verifier-plugin\`プロジェクトが開発するカスタムGradleプラグインの実装コードをここで示します。

I learned ["Writing Custom Gradle Plugins", Baeldung](https://www.baeldung.com/gradle-create-plugin).

### org.myorg.UrlVerifierPlugin class

`UrlVerifierPlugin` クラスがカスタムGradleプラグインの本体です。パラメータ `url` としてURL文字列を受け取ることができます。プラグインは実行されると指定されたURLに対してHTTP GETリクエストを送り、HTTP応答のステータスが200 OKであるかどうかを調べます。もし200ならプラグインは "Successfully resolved URL" と言うメッセージを、さもなければ "Failed to resolve URL" と言うメッセージを標準出力に表示します。

![file](./images/file.png) `url-verifier-plugin/src/main/java/org/myorg/UrlVerifierPlugin.java`

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

### org.myorg.UrlVerifierExtension class

![file](./images/file.png) `url-verifier-plugin/src/main/java/org/myorg/UrlVerifierExtension.java`

    package org.myorg;

    public class UrlVerifierExtension {
        public String url;

        public String getUrl() {
            return url;
        }
    }

### org.myorg.tasks.UrlVerify class

![file](./images/file.png) `url-verifier-plugin/src/main/java/org/myorg/tasks/UrlVerify.java`

    package org.myorg.tasks;

    import org.gradle.api.DefaultTask;
    import org.gradle.api.provider.Property;
    import org.gradle.api.tasks.Input;
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
                System.out.println(String.format("Successfully resolved URL '%s'", getUrl().get()));
            } else {
                System.err.println(String.format("Failed to resolve URL '%s'", getUrl().get()));
            }
        }
    }

### org.myorg.http.DefaultHttpCaller class

![file](./images/file.png) `url-verifier-plugin/src/main/java/org/myorg/http/DefaultHttpCaller.java`

    package org.myorg.http;

    import java.io.IOException;
    import java.net.HttpURLConnection;
    import java.net.URL;

    public class DefaultHttpCaller implements HttpCaller {
        @Override
        public HttpResponse get(String url) throws HttpCallException {
            try {
                HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
                connection.setConnectTimeout(5000);
                connection.setRequestMethod("GET");
                connection.connect();

                int code = connection.getResponseCode();
                String message = connection.getResponseMessage();
                return new HttpResponse(code, message);

            } catch (IOException e) {
                throw new HttpCallException(String.format("Failed to call URL '%s' via HTTP GET", url), e);
            }
        }
    }

### org.myorg.http.HttpCaller class

![file](./images/file.png) `url-verifier-plugin/src/main/java/org/myorg/http/HttpCaller.java`

    package org.myorg.http;

    public interface HttpCaller {

        HttpResponse get(String url) throws HttpCallException;
    }

### org.myorg.http.HttpResponse class

![file](./images/file.png) `url-verifier-plugin/src/main/java/org/myorg/http/HttpResponse.java`

    package org.myorg.http;

    public class HttpResponse {
        private int code;
        private String message;

        public HttpResponse(int code, String message) {
            this.code = code;
            this.message = message;
        }

        public int getCode() {
            return code;
        }

        public String getMessage() {
            return message;
        }

        @Override
        public String toString() {
            return "HTTP " + code + ", Reason: " + message;
        }
    }

## 自動化されたテスト

### テストのソースのディレクトリ構造

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

### Configuring Testing Framework "Spock"

We use the testing framework [Spock](https://spockframework.org/) for all of unit-test, integration test and functional test. If you prefer, you can use JUnit or TestNG, of course.

We declare the dependency to the Spock in `url-verifier-plugin/build.gradle` and `url-verifier-plugin/settings.gradle` as follows.

![file](./images/file.png) `url-verifier-plugin/build.gradle`

    dependencies {
        // we will use Spock frame for testing
        testImplementation platform(libs.spock.bom)
        testImplementation libs.spock.core
        integrationTestImplementation platform(libs.spock.bom)
        integrationTestImplementation libs.spock.core
        functionalTestImplementation platform(libs.spock.bom)
        functionalTestImplementation libs.spock.core

What is `platform(…​)`? See [Gradle doc, "Sharing dependency versions between projects / Using a platform to control transitive versions"](https://docs.gradle.org/current/userguide/platforms.html#sub:using-platform-to-control-transitive-deps) for what `platform(…​)` notation does.

![file](./images/file.png) `url-verifier-plugin/settings.gradle`

    dependencyResolutionManagement {
        versionCatalogs {
            libs {
                version('spock', '2.0-groovy-3.0')
                library('spock-core', 'org.spockframework', 'spock-core').versionRef('spock')
                library('spock-bom', 'org.spockframework', 'spock-bom').versionRef('spock')
            }
        }
    }

Here I used
["Version Catalog"](https://docs.gradle.org/current/userguide/platforms.html). The Version Catalog enables me to make an alias (`libs.spock.core`) to a fully qualified dependency declaration `"org.spockframework:spock-core:2.0-groovy-3.0"`. Please note that the version number `2.0-groovy-3.0` is written only once in the entire configuration files. Thus I can respect the *Don’t Repeat yourself* principle.

### Code for Unit test

The following code performs unit-leve test for `org.myorg.http.HttpResponse` class.

![file](./images/file.png) `url-verifier-plugin/src/test/groovy/org/myorg/http/HttpResponseTest.groovy`

    package org.myorg.http

    import spock.lang.Specification

    class HttpResponseTest extends Specification {

        private static final int OK_HTTP_CODE = 200
        private static final String OK_HTTP_MESSAGE = 'OK'

        def "can access information"() {
            when:
            def httpResponse = new HttpResponse(OK_HTTP_CODE, OK_HTTP_MESSAGE)

            then:
            httpResponse.code == OK_HTTP_CODE
            httpResponse.message == OK_HTTP_MESSAGE
        }

        def "can get String representation"() {
            when:
            def httpResponse = new HttpResponse(OK_HTTP_CODE, OK_HTTP_MESSAGE)

            then:
            httpResponse.toString() == "HTTP ${OK_HTTP_CODE}, Reason: ${OK_HTTP_MESSAGE}"
        }
    }

You can extend the `HttpResponseTest` class to cover more cases. You can also add more of unit-tests for other classes in the `main` source set, of course.

### Code for Integration test

The following test code makes an HTTP request to an external URL ("https://www.google.com/"). This requires connectivity to the Internet, and it assumes that the external URL is available when you execute this test. When the external resources are not accessible, this test will fail.

We categorise those tests that depend on external resources as "Integration Test" and separate them from the unit-tests.

![file](./images/file.png) `url-verifier-plugin/src/integrationTest/groovy/org/myorg/http/DefaultHttpCallerIntegrationTest.groovy`

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

### Code for Functional test

The following test code runs the custom Gradle plugin and verifies the outcomes of the plugin.

-   The test code generates a "build.gradle" in a temporary file which loads the custom plugin of id `org.myorg.url-verifier`.

-   The plugin automatically adds a custom task `:verifyUrl` into the project constructed with the temporary build file.

-   The test code runs Gradle just in the same way as you type in the console:

<!-- -->

    $ gradle verifyUrl https://www.google.com/

-   The test code fetches the output from the custom plugin and verifies it.

![file](./images/file.png) `url-verifier-plugin/src/functionalTest/groovy/org/myorg/UrlVerifierPluginFunctionalTest.groovy`

    package org.myorg

    import org.gradle.testkit.runner.GradleRunner
    import spock.lang.Specification
    import spock.lang.TempDir

    import static org.gradle.testkit.runner.TaskOutcome.SUCCESS

    class UrlVerifierPluginFunctionalTest extends Specification {

        @TempDir File testProjectDir
        File buildFile

        def setup() {
            buildFile = new File(testProjectDir, 'build.gradle')
            buildFile << """
                plugins {
                    id 'org.myorg.url-verifier'    
                }
            """
        }

        def "can successfully configure URL through extensions and verify it"() {
            buildFile << """
                verification {
                    url = 'https://www.google.com/'
                }
            """

            when:
            def result = GradleRunner.create()
                    .withProjectDir(testProjectDir)
                    .withArguments('verifyUrl')
                    .withPluginClasspath()
                    .build()

            then:
            result.output.contains("Successfully resolved URL 'https://www.google.com/'")
            result.task(":verifyUrl").outcome == SUCCESS
        }
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

I must confess, I do not understand the terms here: `includeBuild`, `dependencySubstitution`, `substitute` and `module`.

## How I revised the original

This project of mine is based entirely on the Gradle project’s documentation:

-   [`Testing Gradle plugins`](https://docs.gradle.org/current/userguide/testing_gradle_plugins.html)

I will call this article as "the original". My sample code set has some differences from the original. Let me enumerate the differences and add some explanations.

### How to construct Composite projects

The original proposes a way how the consumer project is associated with the plugin development project, as follows:

![file](./images/file.png) `include-plugin-build/build.gradle`

    plugins {
        id 'org.myorg.url-verifier'
    }

![file](./images/file.png) `include-plugin-build/settings.gradle`

    pluginManagement {
        includeBuild '../url-verifier-plugin'
    }

This didn’t work for me. [When I ran it](https://github.com/kazurayam/TestingGradlePlugins-revised/issues/1), I got the following error:

    $ basename $(pwd)
    include-plugin-build
    $ gradle verifyUrl

    FAILURE: Build failed with an exception.

    * Where:
    Build file '/Users/kazuakiurayama/tmp/url-verifier-gradle-plugin/include-plugin-build/build.gradle' line: 2

    * What went wrong:
    Plugin [id: 'org.myorg.url-verifier'] was not found in any of the following sources:

    - Gradle Core Plugins (plugin is not in 'org.gradle' namespace)
    - Included Builds (None of the included builds contain this plugin)
    - Plugin Repositories (plugin dependency must include a version number for this source)
    ...

So I revised this part as follows:

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

![file](./images/file.png) `include-plugin-build/settings.gradle`

    // include the build of the plugin development project
    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            // explicitly load the output of the included build
            // into the consumer project's classpath
            substitute(module("org.myorg:url-verifier"))
        }
    }

I learned this from an article
[Gradle plugins and Composite builds](https://ncorti.com/blog/gradle-plugins-and-composite-builds) by ncorti.

### Why not doing publishToMavenLocal?

I could publish the custom Gradle plugin `org.myorg.url-verifier` to the mavenLocalRepository. How to?

![file](./images/file.png) `url-verifier-plugin/build.gradle`

    plugins {
        id 'groovy'
        id 'java-gradle-plugin'
        id 'maven-publish'
    }

    group 'org.myorg'
    version '1.2.1-SNAPSHOT'

    repositories {
        mavenCentral()
    }

and I execute the following command:

    $ basename $(pwd)
    url-verifier-plugin
    $ ./gradlew publishToMavenLocal

then I got the plugin’s jar file saved:

    $ pwd
    /Users/kazuakiurayama/.m2/repository/org/myorg/url-verifier-plugin/1.2
    $ ls -la
    total 32
    drwxr-xr-x  5 kazuakiurayama  staff   160  6 22 11:03 .
    drwxr-xr-x  7 kazuakiurayama  staff   224  6 22 11:03 ..
    -rw-r--r--  1 kazuakiurayama  staff  5840  6 22 11:03 url-verifier-plugin-1.2.jar
    -rw-r--r--  1 kazuakiurayama  staff  1916  6 22 11:03 url-verifier-plugin-1.2.module
    -rw-r--r--  1 kazuakiurayama  staff   757  6 22 11:03 url-verifier-plugin-1.2.pom

Once the plugin’s jar is published in the mavenLocal repository, the following configuration also worked.

![file](./images/file.png) `include-plugin-build/build.gradle`

    buildscript {
        repositories {
            mavenLocal()
        }
        dependencies {
            classpath 'org.myorg:url-verifier-plugin:1.2'
        }
    }
    apply plugin: 'org.myorg.url-verifier'

    verification {
        url = 'https://www.google.com/'
    }

![file](./images/file.png) `include-plugin-build/settings.gradle`

    /* I do not use includeBuild */

This way worked. But I wasn’t fully contented with it. Why? I found 2 issues here.

1.  I have to repeat running `publishToMavenLocal` task

2.  The plugin’s version number `1.2` is repeated in 2 build.gradle file

I would definitely repeat changing the plugin and testing it. I do not like to repeat running `publishToMavenLocal` task, I do not like to repeat coding the version number at multiple places.

### integrationTest depends on classes in the main source set

I added the following line:

![file](./images/file.png) `url-verifier-plugin/build.gradle`

        // let the integrationTest refer to the class files
        // of the `main` sourceSet.
        integrationTestImplementation sourceSets.main.output
    }

This single line makes the classes in the `` main source set available for the test class in the `integrationTest `` source set. Without this, the integrationTest does not compile:

    $ basename $(pwd)
    url-verifier-plugin
    $ ./gradlew integrationTest

    > Task :compileIntegrationTestGroovy
    startup failed:
    /Users/kazuakiurayama/github/TestingGradlePlugins-revised/url-verifier-plugin/src/integrationTest/groovy/org/myorg/http/DefaultHttpCallerIntegrationTest.groovy: 11: unable to resolve class HttpCaller
     @ line 11, column 5.
           @Subject HttpCaller httpCaller = new DefaultHttpCaller()
           ^

    /Users/kazuakiurayama/github/TestingGradlePlugins-revised/url-verifier-plugin/src/integrationTest/groovy/org/myorg/http/DefaultHttpCallerIntegrationTest.groovy: 11: unable to resolve class DefaultHttpCaller
     @ line 11, column 38.
           @Subject HttpCaller httpCaller = new DefaultHttpCaller()
                                            ^

    2 errors


    > Task :compileIntegrationTestGroovy FAILED

    FAILURE: Build failed with an exception.

    * What went wrong:
    Execution failed for task ':compileIntegrationTestGroovy'.
    > Compilation failed; see the compiler error output for details.

The original wrote this as:

        integrationTestImplementation(project)

But I prefer writing `sourceSets.main.output` here instead of `project` to be more explicit.

### Added java codes as example

The original misses the source of Java classes.

<table>
<caption>Classes that make the Custom Plugin</caption>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">class name</th>
<th style="text-align: left;">in the original</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/http/DefaultHttpCaller.java">org.myorg.http.DefaultHttpCaller</a></p></td>
<td style="text-align: left;"><p>presented</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/http/HttpCallException.java">org.myorg.http.HttpCallException</a></p></td>
<td style="text-align: left;"><p>missing</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/http/HttpCaller.java">org.myorg.http.HttpCaller</a></p></td>
<td style="text-align: left;"><p>missing</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/http/HttpResponse.java">org.myorg.http.HttpResponse</a></p></td>
<td style="text-align: left;"><p>presented</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/tasks/UrlVerify.java">org.myorg.tasks.UrlVerify</a></p></td>
<td style="text-align: left;"><p>presented</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/UrlVerifierExtension.java">org.myorg.UrlVerifierException</a></p></td>
<td style="text-align: left;"><p>missing</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><a href="https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/main/java/org/myorg/UrlVerifierPlugin.java">org.myorg.UrlVerifierPlugin</a></p></td>
<td style="text-align: left;"><p>presented</p></td>
</tr>
</tbody>
</table>

Classes that make the Custom Plugin

So I guessed how the missing codes should be. I added them in the sample project.
