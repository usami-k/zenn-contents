---
title: "Subject からはじめる Combine"
emoji: "🔗"
type: "tech"
topics: ["swift", "combine", "xcode", "mac", "ios"]
published: true
---

初めて Combine を学ぶ人向けに「[Combineをはじめよう](https://zenn.dev/usamik26/books/a5883603f0260e446698)」という本を書きました。この記事では、その本についての補足のような内容（あるいは裏話のような内容）を書きます。

## Combine をはじめる敷居を下げる

Combine は Swift でリアクティブプログラミングを行うためのフレームワークです。各種の非同期イベントのハンドリングに使うことができます。類似のものとして RxSwift / ReactiveSwift などがあります。Combine は標準フレームワークのひとつとして加わったため、今後、採用事例が増えると思われます。

リアクティブプログラミングには、敷居が高い、学習コストが高い、というイメージがあります。しかし、実はそんなに難しいものではないのです。そこで、上述の本では Combine をはじめる敷居を下げたいと考えました。

最初のほうに、学ぶ方針として以下のように書きました。

> プログラマであれば、言葉であれこれ説明する前に、実際にコードを書いて動かしてみるのが理解が早いだろう

この考えにもとづいて、Xcode Playground ですぐに動かせるコードを用意しました。すぐ動かせるようにすることで敷居を下げる狙いです。

```swift
import Combine

let subject = PassthroughSubject<String, Never>()

subject
    .sink { value in
        print("Received value:", value)
    }

subject.send("あ")
subject.send("い")
subject.send("う")
```

まずはコードを動かして、それからその意味を理解していく、という順序で学ぶのが早いと考えています。

## Publisher に Subject を採用

Combine で非同期イベントを送信するものは Publisher と呼ばれます。まずは Publisher を知るのが Combine を知る第一歩です。上述の本では、最初の Publisher として `PassthroughSubject` を採用しました。このやり方は、他の解説ではあまり見かけません。なぜ Subject を採用したのかを述べます。

Combine の解説でよく使われる Publisher のひとつは、`NotificationCenter` の Publisher です。

```swift
let myNotification = Notification.Name("MyNotification")
let publisher =
    NotificationCenter.default.publisher(for: myNotification)

publisher
    .sink { value in
        print("Received value:", value)
    }
```

`NotificationCenter` は知っている人が多く、導入として分かりやすいという利点があります。また、標準で `publisher` メソッドが用意されていて便利です。一方で欠点があります。単純なイベントしか発生させられないという点です。

Combine のイベントは以下の 3 種類があります。

- 値
- イベント完了（`.finished`）
- エラー（`.failure`）

これらを自由に発生させられるほうが学びやすいと考えます。

そこで Subject の例を挙げます。

```swift
let subject = PassthroughSubject<String, MyError>()

subject.send("あ")
subject.send(completion: .finished)
subject.send(completion: .failure(.failed))

enum MyError: Error {
    case failed
}
```

3 種類のイベントを簡単に発生させられるのが Subject の利点です。この利点は、Xcode Playground でコードを書いて学ぶという方針に合致します。そのため Subject を採用しました。

## Subject の注意点

Subject の採用理由を述べましたが、注意すべき点もあります。

一般的な Publisher はイベントが流れてくるだけのものです。しかし Subject は `send` でイベントを意図的に発生させることができます。便利な機能ですが、これは Publisher としては余分な役割を持っているともいえます。

この点は Subject が Publisher の例として良くない理由であり、他の Combine の解説で Publisher の導入に Subject が採用されない理由です。上述の本では、Xcode Playground でコードを書いて学ぶという方針を重視したため、この点には目をつぶりました。

とはいえ、Subject は悪いものではなく、実際のアプリ開発でもよく使います。

Subject を単なる Publisher として見せる方法があります。

```swift
let subject = PassthroughSubject<String, Never>()
let publisher = subject.eraseToAnyPublisher()
```

Subject の型消去を行い、`AnyPublisher` 型として見せることができます。イベント送信側では `subject` を使い、イベント受信側には `publisher` のほうを使わせるようにするわけです。実際のアプリ設計では、この方法を利用するのが好ましいです。

# まとめ

Combine を学ぶには Xcode Playground を活用するのが良いです。Subject は Xcode Playground での学びに向いています。ただし、一般的な Publisher と異なる点もあるので注意が必要です。

この記事は、[Mobile Act ONLINE #2](https://mobileact.connpass.com/event/189045/) で話した「[Subject からはじめる Combine](https://speakerdeck.com/usamik26/combine-start-with-subject)」を記事の形に改変したものです。
