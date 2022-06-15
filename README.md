# Testing Gradle Plugin

- author: kazurayam
- date: 15 JUNE 2022

The original was the following document published by the Gradle project:

- https://docs.gradle.org/current/userguide/testing_gradle_plugins.html

I read this and got surprised to find how the document is poorly written. It does not provide a distributable archive of working sample code set, with which I can quickly try running the software. Why not? I also found that the explanation of the article is incomplete. The document does not show the code of a few files which are essential to make the software runnable.

I have spent a few days struggling to create a Gradle project which is ready to run and presents a full code set for the article shown above.

このレポジトリはGradleプロジェクトが公開している公式ドキュメントの一部である下記URLの記事を元ネタとして作られました。

わたしはこの記事を読んで正直驚きました。読んでも理解できないんですよ。記事の説明文が懇切丁寧でないのはまあしょうがない。一つの記事の中で何から何まで説明するという訳には行きますまいから。サンプルコード一式をまとめたzipファイルが提供されていてほしかった。そいつをダウンロードしてして解凍し `$ gradle test` とコマンドを実行すればダーーーと動いてくれて、ソースコードをもれなく読むことできることが必要だった。実行可能なzipが提供されていれば、記事の説明が断片的であったとしても省略されたノウハウをソースコードの中から読み取ることができるはずなのだ。ところがzipが提供されていない。なんてことだ。これがGradle本家のドキュメントの出来がこの有り様だとは、私は本当に驚いた。

しょうがない。runnable sample code setを作るしかない。

そういう次第で作ったのがこのレポジトリ。
