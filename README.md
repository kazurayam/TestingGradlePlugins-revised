# Testing Gradle Plugin --- revised

- author: kazurayam
- date: 15 JUNE 2022

The original was the following document published by the Gradle project:

- https://docs.gradle.org/current/userguide/testing_gradle_plugins.html

I read this and got surprised to find how the document is poorly written. It does not provide a distributable archive of working sample code set, with which I can quickly try running the software. Why not? I also found that the explanation of the article is incomplete. The document does not show the code of a few files which are essential to make the software runnable.

I have spent a few days struggling to create a Gradle project which is ready to run and presents a full code set for the article shown above.

このレポジトリはGradleプロジェクトが公開している公式ドキュメントの一部である下記URLの記事を元ネタとして作られました。

わたしはこの記事を読んで驚きました。理解できないんですよ。説明文が懇切丁寧でないことにあまり文句をいうまい。一本の記事の中で何から何まで説明する訳には行きますまいから。しかし、せめて、サンプルコード一式をまとめたzipファイルを提供してほしい。zipファイルをダウンロードしてして解凍すればソースコードがもれなく読めて、コマンドラインで 

`$ gradle test`

と実行すればテストが動いてPASSする、というふうであってほしい。エラー無しに実行可能なコード一式がzipファイルとして提供されていれば、たとえ説明文が不出来であっても、ソースコードの中に学習の手掛かりを見出すことができるのだ。ところがGradle本家のドキュメントはサンプルコードのzipを提供していない。どうもGradleプロジェクトは初心者にもわかるドキュメントを書く気があまりないらしい。

まあ、無いものは無い。しょうがない。私が作りましょう。そういう次第で作ったのがこのレポジトリ。
