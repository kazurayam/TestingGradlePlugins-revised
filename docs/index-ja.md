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
    -   [自動化テストを作る](#自動化テストを作る)
        -   [テストのソースのディレクトリ構造](#テストのソースのディレクトリ構造)
        -   [カスタムなSource SetとカスタムなTaskを作る](#カスタムなsource-setとカスタムなtaskを作る)
        -   [java-gradle-pluginプラグインを設定する](#java-gradle-pluginプラグインを設定する)
        -   [テスト・フレームワーク Spock を使えるようにする](#テストフレームワーク-spock-を使えるようにする)
        -   [ユニット・テストのコード](#ユニットテストのコード)
        -   [インテグレーション・テストのコード](#インテグレーションテストのコード)
        -   [ファンクショナル・テストのコード](#ファンクショナルテストのコード)
    -   [カスタムGradleプラグインを利用する側のプロジェクトの実装例](#カスタムgradleプラグインを利用する側のプロジェクトの実装例)
        -   [別のやり方](#別のやり方)
    -   [オリジナルをどう手直ししたか](#オリジナルをどう手直ししたか)
        -   [Composite projectsの組み立て方](#composite-projectsの組み立て方)
        -   [integrationTestのクラスがmainソースセットに依存していることの表明](#integrationtestのクラスがmainソースセットに依存していることの表明)
        -   [Javaコードを網羅的に例示した](#javaコードを網羅的に例示した)

# カスタムGradleプラグインを自動化テストする方法

-   著者: kazurayam

-   日付: 2022年6月

## はじめに

カスタムなGradleプラグインを開発するにあたってテストをしたい。どういうコードを書けば自動化テストができるか？その方法を説明します。ちゃんと動くサンプルコード一式を提供します。

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

![console](https://kazurayam.github.io/TestingGradlePlugins-revised/images/console.png)

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

![console](https://kazurayam.github.io/TestingGradlePlugins-revised/images/console.png)

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

`:invlude-plugin-build` プロジェクトの `:verifyUrl` タスクは `url-verify-plugin` プロジェクトで開発された カスタムGradleプラグイン `org.myorg.url-verifier` を実行して、その結果を検証します。

## ディレクトリ構造

このレポジトリには根ディレクトリとして `TestingGradlePlugins-revised` ディレクトリがあります。その下にディレクトリが二つ（`url-verifier-plugin` と `include-plugin-build`）あって、各々が独立したGradleプロジェクトになっています。.

![console](https://kazurayam.github.io/TestingGradlePlugins-revised/images/console.png)

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

私は ["Writing Custom Gradle Plugins", Baeldung](https://www.baeldung.com/gradle-create-plugin) を参考にしました。

### org.myorg.UrlVerifierPlugin class

`UrlVerifierPlugin` クラスがカスタムGradleプラグインの本体です。パラメータ `url` としてURL文字列を受け取ることができます。プラグインは実行されると指定されたURLに対してHTTP GETリクエストを送り、HTTP応答のステータスが200 OKであるかどうかを調べます。もし200ならプラグインは "Successfully resolved URL" と言うメッセージを、さもなければ "Failed to resolve URL" と言うメッセージを標準出力に表示します。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/main/java/org/myorg/UrlVerifierPlugin.java`

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

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/main/java/org/myorg/UrlVerifierExtension.java`

    package org.myorg;

    public class UrlVerifierExtension {
        public String url;

        public String getUrl() {
            return url;
        }
    }

### org.myorg.tasks.UrlVerify class

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/main/java/org/myorg/tasks/UrlVerify.java`

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

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/main/java/org/myorg/http/DefaultHttpCaller.java`

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

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/main/java/org/myorg/http/HttpCaller.java`

    package org.myorg.http;

    public interface HttpCaller {

        HttpResponse get(String url) throws HttpCallException;
    }

### org.myorg.http.HttpResponse class

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/main/java/org/myorg/http/HttpResponse.java`

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

## 自動化テストを作る

### テストのソースのディレクトリ構造

カスタムGradleプラグインを開発するプロジェクトの名前は `url-verifier-plugin` です。このプロジェクトにはソースコードを格納するためのディレクトリが４つあります。すなわち

1.  `src/main/`

2.  `src/test/`

3.  `src/integrationTest/`

4.  `src/functionalTest/`

これらサブディレクトリがGradleの[Source Set](https://www.baeldung.com/gradle-source-sets)に対応します。

![console](https://kazurayam.github.io/TestingGradlePlugins-revised/images/console.png)

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

`src/main/` ディレクトリにはカスタムGradleプラグイン本体のJavaソースコードが格納されています。

残り３つのディレクトリには自動化テストのコードが格納されています。

`src/test/` ディレクトリには\`src/main\`のコードをユニット・テストするためのコードが格納されています。

`src/integrationTest/` ディレクトリにはインテグレーション・テストのためのコードが格納されています。インテグレーション・テストとはそれを実行するのに他のリソース（\`http://\`で始まるURLやデータベース）と接続する必要があるテストです。

`src/functionalTest/` ディレクトリにはファンクショナル・テストのためのコードが格納されています。ファンクショナル・テストとはテスト対象であるカスタムGradleプラグインを利用者の視点からテストするものです。ファンクショナル・テストはカスタムGradleプラグインを呼び出すような\`build.gradle\`ファイルを動的に生成し即座に実行します。そしてプラグインからの出力を調べてプラグインの動作を検証します。

### カスタムなSource SetとカスタムなTaskを作る

Gradleは *Source sets* という概念をもっています。Source Setによってプログラムのソースコード群を分類することができます。*Source Sets* についてわたしは ["Gradle Source Sets", Baeldung](https://www.baeldung.com/gradle-source-sets) を参考にしました。

ちなみに `url-verifier-plugin` プロジェクトは `groovy` プラグインと `java-gradle-plugin` プラグインを使っています。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/build.gradle`

    plugins {
        id 'groovy'
        id 'java-gradle-plugin'

`groovy` プラグインを適用することにより、`url-verifier-plugin` プロジェクトのなかに２つの source sets が自動的につくられます。すなわち `main` と `test` です。

`main` ソースセットは `url-verifier-plugin/src/main/` ディレクトリに格納されたソースコードに対応します。そこにはカスタムプラグインのソースがあります。

`test` ソースセットは `url-verifier-plugin/src/test/` ディレクトリに格納されたソースコードに対応します。そこにはユニットテストのソースがあります。

あと２つ、ソースセットを明示的に追加しました。すなわち `integrationTest` と `functionalTest` です。どうやって追加したか、次のコードを参照してください。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifyer-plugin/build.gradle`

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

ついでにカスタムタスク `:check` を定義しました。`:check` タスクは `:integrationTest` タスクと `:functionalTest` タスクを呼び出します。

### java-gradle-pluginプラグインを設定する

ファンクショナル・テスト [`UrlVerifierPluginFunctionalTest`](https://github.com/kazurayam/TestingGradlePlugins-revised/blob/master/url-verifier-plugin/src/functionalTest/groovy/org/myorg/UrlVerifierPluginFunctionalTest.groovy) がカスタムGradleプラグインを実行するときに [`org.gradle.testkit.runner.GradleRunner`](https://docs.gradle.org/current/javadoc/org/gradle/testkit/runner/GradleRunner.html) クラスの助けを必要とします。GradleRunnerクラスは [`java-gradle-plugin`](https://docs.gradle.org/current/userguide/java_gradle_plugin.html) プラグインによって提供されます。ファンクショナル・テストのコードに対して\`GradleRunner\`クラスをimport可能にするために、1行だけ設定を書く必要があります。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/build.gradle`

    gradlePlugin {
        // configure the `java-gradle-plugin` so that it looks at the `sourceSets.functionalTest`
        // to find the tests for the custom plugin.
        testSourceSets(sourceSets.functionalTest)
        // This makes `org.gradle.testkit.runner.GradleRunner` class available to the
        // functionalTest classes.
    }

### テスト・フレームワーク Spock を使えるようにする

テスト・フレームワーク [Spock](https://spockframework.org/) を使って自動化テストを書くことにしました。もちろんSpockを使わずJUnitやTestNGを使って書くこともできます。お好みで。

`url-verifier-plugin/build.gradle` ファイルと `url-verifier-plugin/settings.gradle` にSpockに関する設定を記述しました。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/build.gradle`

    dependencies {
        // we will use Spock frame for testing
        testImplementation platform(libs.spock.bom)
        testImplementation libs.spock.core
        integrationTestImplementation platform(libs.spock.bom)
        integrationTestImplementation libs.spock.core
        functionalTestImplementation platform(libs.spock.bom)
        functionalTestImplementation libs.spock.core

`platform(…​)` とは何でしょうか？ [Gradle doc, "Sharing dependency versions between projects / Using a platform to control transitive versions"](https://docs.gradle.org/current/userguide/platforms.html#sub:using-platform-to-control-transitive-deps) に `platform(…​)` 関する説明があります。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/settings.gradle`

    dependencyResolutionManagement {
        versionCatalogs {
            libs {
                version('spock', '2.0-groovy-3.0')
                library('spock-core', 'org.spockframework', 'spock-core').versionRef('spock')
                library('spock-bom', 'org.spockframework', 'spock-bom').versionRef('spock')
            }
        }
    }

ここでわたしは ["Version Catalog"](https://docs.gradle.org/current/userguide/platforms.html) と呼ばれる表記法をとりました。 `"org.spockframework:spock-core:2.0-groovy-3.0"` という長い記述に対する短い別名 (`libs.spock.core`) をVersion Catalogを使って定義しました。別名を使うことにより、`2.0-groovy-3.0` というバージョン番号を書くのを１箇所だけにすることができました。

### ユニット・テストのコード

`org.myorg.http.HttpResponse` クラスに対するユニット・テストのコードは下記の通りです。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/test/groovy/org/myorg/http/HttpResponseTest.groovy`

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

`HttpResponseTest` クラスにメソッドを増やしてもっと網羅的なテストにすることができます。また `main` ソースセットにある他のクラスに対するユニット・テストを追加することもできます。

### インテグレーション・テストのコード

次に示すテストは外部のURL ("https://www.google.com/") にHTTP要求をします。このテストを実行するにはインターネットへの接続が可能な環境が必要であり、かつ外部URLがちゃんと応答してくれることが必要です。これら必要条件が満たされなければこのテストは失敗します。

このように外部リソースに依存するテストを *Integration Test* と呼び、ユニット・テストから区別することにします。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/integrationTest/groovy/org/myorg/http/DefaultHttpCallerIntegrationTest.groovy`

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

### ファンクショナル・テストのコード

次に示すテストはカスタムGradleプラグインを実行し、プラグインの出力を検証します。

-   テストは一時的ファイルとして build.gradle を生成します。そのビルドはカスタムGradleプラグイン `org.myorg.url-verifier` をロードします。

-   カスタムGradleプラグインがロードされると自動的に `:verifyUrl` タスクが追加されます。

-   テストはGradleビルドを実行します。それはあたかも人がコマンドラインで下記のようにコマンドをタイプしたのと同じことです。

<!-- -->

    $ gradle verifyUrl https://www.google.com/

-   カスタムプラグインが完了したらプラグインの出力をテストが取り出して検証します。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/src/functionalTest/groovy/org/myorg/UrlVerifierPluginFunctionalTest.groovy`

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

## カスタムGradleプラグインを利用する側のプロジェクトの実装例

コマンドラインで次のような操作をしてみましょう。`verifyUrl` タスクを実行しています。`verifyUrl` タスクはカスタムGradleプラグイン `org.myorg.url-verifier` を呼び出しています。

![console](https://kazurayam.github.io/TestingGradlePlugins-revised/images/console.png)

    $ basename `pwd`
    TestingGradlePlugins-revised
    $ cd include-plugin-build/
    $ ./gradlew verifyUrl

    > Task :verifyUrl
    Successfully resolved URL 'https://www.google.com/'

    BUILD SUCCESSFUL in 1s
    5 actionable tasks: 1 executed, 4 up-to-date

カスタムプラグインを利用するプロジェクトはどのように作られているのでしょうか？ファイルが２つあります。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/build.gradle`

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

`buildscript {}` クロージャがあって、このビルドスクリプトが `org.myorg:url-verifier-plugin` というgroupとnameをもつライブラリに依存するということを表明しています。それに続く `apply plugin` がライブラリの中からカスタムプラグイン `org.myorg.url-verifier` を取り出して利用するぞと表明しています。`verifycation { url = '…​' }` クロージャはカスタムプラグインが受け取ることのできるパラメータ `url` に対して具体的な値を与えています。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/setting.gradle`

    // include the build of the plugin development project
    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            // explicitly load the output of the included build
            // into the consumer project's classpath
            substitute(module("org.myorg:url-verifier"))
        }
    }

この `settings.gradle` ファイルは `includeBuild` 、`dependencySubstitution`　、 `substitute` 、 `module` などの呪文を使っています。わたしは或る解説記事の一部をコピペして調節しました。このサンプルは実行するとちゃんと動きます。しかしわたしは呪文の意味がまだわかっていません。

### 別のやり方

`url-verifier-plugin` プロジェクトが作ったカスタム・プラグインを\`include-plugin-build\` プロジェクトが実行できるように構成する方法がもう一つあります。`org.myorg.url-verifier` を含むJARファイルを作って、それをMavenレポジトリにpublishする。publishされたJARファイルを `include-plugin-build` プロジェクトが参照する、と言うやり方です。`maven-publish` プラグインを使ってJARを作り mavenLocalレポジトリに publishしましょう。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/build.gradle`

    plugins {
        id 'groovy'
        id 'java-gradle-plugin'
        id 'maven-publish'
    }

    group 'org.myorg'
    version '1.2.1'

    repositories {
        mavenCentral()
    }

そしてコマンドラインで次のようにコマンドを実行する。

    $ basename $(pwd)
    url-verifier-plugin
    $ ./gradlew publishToMavenLocal
    ...

そうするとJARファイルが作られました。

    $ pwd
    /Users/kazurayam/.m2/repository/org/myorg/url-verifier-plugin/1.2
    $ ls -la
    total 32
    drwxr-xr-x  5 kazurayam  staff   160  6 22 11:03 .
    drwxr-xr-x  7 kazurayam  staff   224  6 22 11:03 ..
    -rw-r--r--  1 kazurayam  staff  5840  6 22 11:03 url-verifier-plugin-1.2.jar
    -rw-r--r--  1 kazurayam  staff  1916  6 22 11:03 url-verifier-plugin-1.2.module
    -rw-r--r--  1 kazurayam  staff   757  6 22 11:03 url-verifier-plugin-1.2.pom

カスタムプラグインを含むJARが mavenLocal レポジトリに作られた後であれば、下記のように設定すればOKです。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/build.gradle`

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

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/settings.gradle`

    /* I do not use includeBuild */

このやり方はちゃんと動きます。しかしこのやり方には良くないところがある。２つ問題があります。

1.  プラグインのコードを変更した後テストするたびに `publishToMavenLocal` タスクを繰り返し実行しなければならないのが面倒だ。

2.  プラグインのバージョン番号（`1.2`)が２箇所に書いてある。`url-verifier-plugin/build.gradle` ファイルのなかに書いてあるのは当然だが、`include-plugin-build/build.gradle` ファイルにも書いてあるのがまずい。バージョンを変更しようとする時、片方のファイルだけ修正してもう片方を忘れるリスクがある。

## オリジナルをどう手直ししたか

このレポジトリが示すサンプルコードはGradleプロジェクトが公開している下記の記事に基づいています。
- [`Testing Gradle plugins`](https://docs.gradle.org/current/userguide/testing_gradle_plugins.html)

この記事のことを指して「オリジナル」と呼ぶことにします。わたしが組み立てたサンプルコードはオリジナルと違うところがいくつかあります。どこを手直ししたのか、下記に列挙します。

### Composite projectsの組み立て方

プラグイン利用者側プロジェクトをどうやってプラグイン開発プロジェクトと関連づけるかという問題があります。

オリジナル記事は次のようなコードを示しています。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/build.gradle`

    plugins {
        id 'org.myorg.url-verifier'
    }

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/settings.gradle`

    pluginManagement {
        includeBuild '../url-verifier-plugin'
    }

このやり方は動きませんでした。 [いざ動かすと](https://github.com/kazurayam/TestingGradlePlugins-revised/issues/1)次のようなエラーが発生しました。

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

わたしは次のように手直ししました。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/build.gradle`

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

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `include-plugin-build/settings.gradle`

    // include the build of the plugin development project
    includeBuild("../url-verifier-plugin") {
        dependencySubstitution {
            // explicitly load the output of the included build
            // into the consumer project's classpath
            substitute(module("org.myorg:url-verifier"))
        }
    }

この書き方をわたしは
["Gradle plugins and Composite builds" by ncorti](https://ncorti.com/blog/gradle-plugins-and-composite-builds) という記事で習いました。

### integrationTestのクラスがmainソースセットに依存していることの表明

下記のコードを参照のこと。

![file](https://kazurayam.github.io/TestingGradlePlugins-revised/images/file.png) `url-verifier-plugin/build.gradle`

        // let the integrationTest refer to the class files
        // of the `main` sourceSet.
        integrationTestImplementation sourceSets.main.output
    }

`integrationTest` ソースセットのなかのテストclassが
`main` ソースセットのなかにあるプラグインclassをimportします。だからこの1行が必要になります。この1行が無いと \`integrationTest\`のコードはコンパイルできません。下記のようなエラーになります。

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

オリジナルはこの1行を次のように書いています。

        integrationTestImplementation(project)

projectを参照するって、どういう意味か？

わたしはここを `sourceSets.main.output` を参照するという風に限定的に書くことにした。同じ結果になるので、趣味の問題ですが。

### Javaコードを網羅的に例示した

オリジナルはいくつかのJavaクラスのソースを示さず省略しています。

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

オリジナルが省略したclassもあわせ、すべてのコードをサンプルに含めました。
