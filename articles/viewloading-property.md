---
title: "@ViewLoadingプロパティラッパの紹介と自前で実装する方法"
emoji: "🔍"
type: "tech"
topics: ["Swift","iOS","UIKit"]
published: true
publication_name: "yumemi_inc"
---

iOS 16.4で追加された `@ViewLoading` プロパティラッパについて紹介し、古いOSでも使えるように自前で実装する方法を述べます。

# `@ViewLoading` とは

`@ViewLoading` プロパティラッパは、2023年3月にリリースされたiOS 16.4で追加された機能です。iOSのマイナーバージョンアップでのSDKの機能追加は比較的めずらしいですね。

このプロパティラッパのおかげで、`UIViewController` のプロパティが扱いやすくなります。

## `UIViewController` のプロパティ

次のコードは、Appleのリファレンスドキュメント（[UIViewController.ViewLoading](https://developer.apple.com/documentation/uikit/uiviewcontroller/viewloading)）から流用しています。

```swift
class DateViewController: UIViewController {
    private var dateLabel: UILabel! // Optional型

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: self.view.bounds)
        self.view.addSubview(label)
        self.dateLabel = label
    }
}
```

このコードの `dateLabel` プロパティは、`viewDidLoad()` で値を設定したらその後は `nil` になりません。このため、Optional型にするのは冗長に感じられます。できれば非Optional型にしたいです。

しかしプロパティを非Optional型にするためには、Swiftの仕様として、クラスの初期化時にプロパティの値の設定が必要になります。今回のケースでは、初期化時でなく `viewDidLoad()` でプロパティの値を設定しています。このため、Optional型にせざるを得ません。

## `@ViewLoading` プロパティラッパ

次のコードでは、`dateLabel` プロパティに `@ViewLoading` プロパティラッパをつけています。

```swift
class DateViewController: UIViewController {
    @ViewLoading private var dateLabel: UILabel // 非Optional型

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: self.view.bounds)
        self.view.addSubview(label)
        self.dateLabel = label
    }
}
```

`dateLabel` プロパティに `@ViewLoading` プロパティラッパをつけることで、非Optional型で宣言できるようになります。実はプロパティラッパの内部ではOptional型で値を持っています。プロパティへの `get` アクセス時に内部の値をunwrapして返してくれます。

しかし、`get` アクセス時にまだプロパティの値が設定されていなかったらどうなるのでしょうか。もし内部の値が `nil` だったら、`get` アクセス時のunwrapで実行時エラーとなってしまいそうです。

ここが `@ViewLoading` プロパティラッパの便利なところです。`get` アクセス時、値を返す前に自動的にViewのロードを行ってくれるのです。

* `get` アクセス
    * → `loadView()` が実行される
    * → `viewDidLoad()` が実行される
    * → 内部の値がunwrapして返される

このため、`viewDidLoad()` でプロパティの値を設定するように実装してあれば、`nil` のunwrapになることはありません。

:::message
`viewDidLoad()` でプロパティの値を設定し忘れると実行時エラーになりますので注意が必要です。`@ViewLoading` プロパティラッパを指定したプロパティは、`viewDidLoad()` で値を設定するように実装してください。
:::

## 利用例

実際に、Viewのロード前の時点でプロパティにアクセスするコードの例を見てみましょう。

```swift
class DateViewController: UIViewController {
    var date: Date? {
        didSet {
            guard let date else { return }
            let dateString = self.dateFormatter.string(from: date)
            self.dateLabel.text = dateString
        }
    }
}
```

`date` プロパティの `didSet` の中で `dateLabel` プロパティにアクセスしています。そのため、この時点で `dateLabel` プロパティの値が設定されている必要があります。

しかし次のように `DateViewController` を利用した場合は、`date` へのアクセス時点ではViewのロードが行われていません。

```swift
let dateViewController = DateViewController()
dateViewController.date = Date()
```

このため `dateLabel` プロパティについて `@ViewLoading` を使っていない場合は実行時エラーになります。一方、`@ViewLoading` を使っている場合は正常に動作します。

ここまでに挙げたコードはAppleのリファレンスドキュメントから流用したものです。ただし、一部変更を加えています。

https://developer.apple.com/documentation/uikit/uiviewcontroller/viewloading

変更した箇所を含めて、改めて全体像を挙げておきます。次のコードはXcode Playgroundで実行できます。

```swift
import UIKit

class DateViewController: UIViewController {
    @ViewLoading private var dateLabel: UILabel

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()

    var date: Date? {
        didSet {
            guard let date else { return }
            let dateString = self.dateFormatter.string(from: date)
            self.dateLabel.text = dateString
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: self.view.bounds)
        self.view.addSubview(label)
        self.dateLabel = label
    }
}

let dateViewController = DateViewController()
dateViewController.date = Date()
```

# `@ViewLoading` を自前で実装する方法

`@ViewLoading` は便利な機能ですが、iOS 16.4以降でしか使えません。そこで、それ以前のバージョンで使うために自前で実装することを考えます。

プロパティラッパはSwiftの言語機能であり自作できます。

## リファレンス実装

`@ViewLoading` を実現するには、プロパティへの `get` アクセスに割り込んで `UIViewController` のメソッドを呼び、Viewのロードができれば良いです。

しかし、通常の方法ではどうも難しいことに気づきます。とくに `UIViewController` のメソッドを呼ぶ手段が分かりません。

幸いなことに、リファレンス実装を作っている方がおられました。これを参考にします。

https://indiestack.com/2023/04/magic-loading-property-wrappers/

## プロパティラッパの通常の実装方法

プロパティラッパの実装方法は、Swiftのドキュメントに記載されています。

https://www.swiftlangjp.com/language-guide/properties.html

次のコード例は、Swiftのドキュメントから引用しています。

```swift
@propertyWrapper
struct TwelveOrLess {
    private var number = 0
    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, 12) }
    }
}
```

`wrappedValue` プロパティを定義した構造体を作成しています。これでプロパティラッパが実装できています。文法が分かってしまえばそれほど難しくはありません。

プロパティラッパの実装は、このプロパティを含む構造体やクラスからは独立しています。きれいな設計ですが、今回のようにプロパティを含むクラスのメソッドを呼びたい場合には制約となってしまいます。

## プロパティラッパの第二の実装方法

実はプロパティラッパの実装方法は他にもあります。

```swift
@propertyWrapper
struct EnclosingTypeReferencingWrapper<Value> {
    static subscript<T>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value  {
        get { ... }
        set { ... }
    }
}
```

このような `subscript` メソッドを定義した構造体を作成することでもプロパティラッパが実装できます。この方法では、引数の `instance` にはプロパティを含むクラスのインスタンスが渡されます。

ひとつ制約として、`ReferenceWritableKeyPath` を利用するため、プロパティを含む型が参照型でなくてはなりません。

この実装方法はSwiftのドキュメントには記載されていません。ただ、プロポーザルには記載があります（[SE-0258 Property Wrappers](https://github.com/apple/swift-evolution/blob/main/proposals/0258-property-wrappers.md)）。また、次のブログ記事で詳しく紹介されています。

https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/

## `@ViewLoading` の実装

`subscript` メソッドの方法で `@ViewLoading` を実装してみます。名前は `@MagicViewLoading` としています（注意：このコードは実際にビルドするには少し修正が必要です。ビルドできるコードは後述します）。

```swift
@propertyWrapper
public struct MagicViewLoading<Value> {
    private var stored: Value?

    public static subscript<T: UIViewController>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance.loadViewIfNeeded()
            return instance[keyPath: storageKeyPath].stored!
        }
        set {
            instance[keyPath: storageKeyPath].stored = newValue
        }
    }
}
```

この構造体の内部プロパティ `stored` へのアクセスでKeyPathが必要になりますが、それ以外はシンプルです。この実装で、以下のような流れになってやりたいことが実現できています。

* `get` アクセス
    * → `loadViewIfNeeded()` を呼ぶ
    * → `viewDidLoad()` から `set` が呼ばれて `stored` に値が設定される
    * → 内部の値 `stored` をunwrapして返す

先ほどの `DateViewController` に `@MagicViewLoading` を適用してみます。実は上記のコードそのままではビルドできないので、少し変更しています。次のコードはXcode Playgroundで実行できます。

```swift
@propertyWrapper
public struct MagicViewLoading<Value> {
    private var stored: Value?

    public init() {}

    @available(iOS 2.0, *)
    public static subscript<T: UIViewController>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance.loadViewIfNeeded()
            return instance[keyPath: storageKeyPath].stored!
        }
        set {
            instance[keyPath: storageKeyPath].stored = newValue
        }
    }

    @available(*, unavailable)
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}

class DateViewController: UIViewController {
    @MagicViewLoading private var dateLabel: UILabel

（後略）
```

より汎用的なリファレンス実装は、次のリポジトリで公開されています。

https://github.com/danielpunkass/MagicLoading

# まとめ

* iOS 16.4で `@ViewLoading` という便利機能が追加された
* それ以前のバージョンでも同様の機能の実現が可能
    * ただしSwiftのドキュメントに記載されていない方法なので注意

なお、この記事は先日のYUMEMI.grow Mobile #6で発表した内容を整理して記事の形にまとめたものです。

https://speakerdeck.com/usamik26/at-viewloading-property-wrapper-implementation
