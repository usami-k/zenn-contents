---
title: "Apple Pencil のホバー機能を試す"
emoji: "🖊️"
type: "tech"
topics: ["ApplePencil","iPadOS","iOS","Swift"]
published: false
---

2022年10月に発売された最新のiPad Proでは、Apple Pencilのホバー状態（iPad Proに直接タッチしておらず少し浮かせている状態）を検出できるようになりました。この機能は、サードパーティ製のアプリでも利用できます。

# 前提条件

ホバー状態の検出機能を使うには、以下のものが必要です。最新のiPad Proでしか使えないという条件が厳しいところです。

* iPadOS 16.1（リリース日：2022-10-25）
* M2 iPad Pro（発売日：2022-10-26）
    * iPad Pro 11-inch 4th gen
    * iPad Pro 12.9-inch 6th gen
* Apple Pencil 2nd gen（これは以前からある）

# 実機での挙動

Apple Pencilのホバー状態を検出できるのは、タッチパネルから約1cm以内にペン先があるときです。

iPadOS標準のメモアプリはホバー状態の検出に対応しており、次のような挙動をします。

* 手書きモードで、ペン先が浮いている状態でペンのタッチ位置がプレビュー表示される
* ボタンなどのUIコントロールの上にかざすと、そのコントロールがハイライト表示される

# アプリでの検出方法

この機能はサードパーティ製のアプリでも利用できます。

具体的には [`UIHoverGestureRecognizer`](https://developer.apple.com/documentation/uikit/uihovergesturerecognizer) を使えば良いです。他のGesture Recognizerと実装方法は同じです。

```swift
let hover = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
button.addGestureRecognizer(hover)

@objc
private func hovering(_ recognizer: UIHoverGestureRecognizer) {
    // 検出時の処理
}
```

実装例として、Appleのサンプルが参考になります。

* [Adopting hover support for Apple Pencil](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/adopting_hover_support_for_apple_pencil)

# UIHoverGestureRecognizer

上述の `UIHoverGestureRecognizer` はiPadOS 13から存在しています。iPadOS 13は、iOSからiPadOSが分離した最初のバージョンでした。

このバージョンから、iPadはマウス操作に対応しています。 `UIHoverGestureRecognizer` はViewの上をマウスポインターがホバーしたことを検出できるものでした。これがiPadOS 16.1からApple Pencilのホバーも検出するようになりました。

つまり、Apple Pencilのホバーは、マウスポインターのホバーと同じ挙動が期待されていると考えられます。

* UIコントロールのハイライト表示など
* 標準のUIコントロールは自動的に対応する

# zOffset

`UIHoverGestureRecognizer` プロパティ [`zOffset`](https://developer.apple.com/documentation/uikit/uihovergesturerecognizer/4098402-zoffset) がiPad16.1で追加されました。

* 0〜1の値でタッチパネルからの距離が取得できる
* Apple Pencilでない場合は常に0の値

`zOffset` でApple Pencilかどうかを判別でき、距離も取得できます。このため、ペン先のタッチ位置のプレビュー表示に活用できます。

ただ、どのようなプレビュー表示をするのが良いかは、現在はガイドラインがない状態です。

* 標準メモアプリは単純にポイント位置を点で表示している？（ひょっとしたらアルファ値も微妙に変えているかも？）
* 上述のサンプルコードでは、点で表示するのに加えて、距離によってアルファ値を変えている（これは見た目の変化が少ないため、意味があるかどうか？）

標準メモアプリやサンプルコードの対応が妥当かどうかは悩むところです。ただ、実際の使用感としては、このくらい単純な表示でも、ユーザーにとっての使い勝手は向上しそうです。

# ホバー検出の有効化・無効化

なお、このホバー検出はユーザーの設定によって無効化できます。ユーザーがApple Pencilの設定のうち「Pencilを使用するときにエフェクトを表示」をオフにしているとホバー検出できませんので、ご注意ください。

![](https://github.com/usami-k/technote/raw/main/2022/pencil-hover/preferences.jpeg)

# 備考

この記事はpotatotips #79で話した内容をもとにしています。
[Apple Pencilのホバー機能を試す / pencil hover - Speaker Deck](https://speakerdeck.com/usamik26/pencil-hover)

