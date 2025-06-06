---
title: "rsync の delete オプション各種"
emoji: "🔄"
type: "tech"
topics: ["shell", "cli"]
published: true
---

[rsync](https://rsync.samba.org/) は、高速な差分ファイル転送ができるコマンドラインツールです。

さまざまな用途に使えるツールですがとくに、ディレクトリ間の同期を行ったり、ディレクトリのバックアップを作成したりする場合に使われることが多いです。その際によく使われるオプションとして `-a`（`--archive`）と `--delete` があります。

このうち `--delete` については、細かい挙動が異なるいくつかのオプションが存在しています。このオプションを紹介します。

# deleteオプションとは

`rsync` の `--delete` オプションは、転送元のディレクトリに存在せず転送先のディレクトリに存在するファイルがあれば削除する、というオプションです。

典型的な使い方を挙げます。`src` ディレクトリを `backup` ディレクトリの下にバックアップするには、以下のようにオプションを指定して実行すれば良いです。

```
rsync -a --delete src backup
```

このコマンドの `-a` オプションによって、`src` 以下のファイルの各種プロパティを保持して `backup` にコピーします。`--delete` オプションによって、`src` から削除されているファイルは `backup` からも削除します。

# さまざまなdeleteオプション

rsync version 3.2.3 の man ページによれば、`--delete` と同じ処理を行うオプションが 4 種類存在しています。これらはどれも `--delete` と同じようにファイルを削除するオプションであり、同じ結果をもたらします。異なるのは、「いつ」ファイルを削除するかです。

- `--delete-before` : ファイルの転送を開始する前に、削除するファイルを走査して転送先からファイルを削除する。
- `--delete-during` : ファイルを転送しながら、削除すべきファイルが見つかれば削除する。
- `--delete-delay` : ファイルを転送しながら、削除すべきファイルを記録しておき、転送が終了した後に転送先からファイルを削除する。
- `--delete-after` : ファイルの転送が終了した後に、削除するファイルを走査して転送先からファイルを削除する。

なお、「いつ」を明示的に指定しない `--delete` オプションは、rsync 3.0.0 以降では `--delete-during` と同じ動作をします。また、それより古いバージョンでは `--delete-before` と同じ動作をします。

# どのオプションを使うべきか

削除処理のタイミングを細かく検討したいなら、マニュアルにメリットとデメリットが書いてあるので、それを読んで吟味するのが良いでしょう。この記事は単にオプションを紹介しているだけですので、より詳しく知りたいならマニュアルを読むべきです。

そのうえで、簡単な指針を書いてみます。

そもそもとくにこだわりがなければ `--delete` で良いでしょう。途中の挙動が少し異なるだけで結果は同じなのですから、用意されているデフォルトの処理に合わせるのが妥当です。

多くの状況では `--delete-during` が効率が良さそうです。rsync 3 ではデフォルトの挙動です。rsync 2 でもこの挙動にしたい場合は明示的に指定します。

転送先に空き容量が少ない場合は、先に転送先のファイルを削除する `--delete-before` が有益です。ただし、同期するファイルが多い場合は全体の走査やファイルの削除に時間がかかるため、実際の転送が行われるまでに時間がかかるというデメリットがあります。場合によっては、転送が行われる前にタイムアウトしてしまう可能性が考えられます。

ファイルの削除よりも先にファイルの転送を終わらせてしまいたい、という考え方もあります。転送先の空き容量が十分ならば、削除はそれほど優先しなくても良いでしょう。その場合は `--delete-after` または `--delete-delay` が良さそうです。

# 補足

delete オプションは、転送先のディレクトリからファイルを削除する処理であり破壊的な操作ですので、実行時には間違えないように注意が必要です。

たとえば `rsync` を使う際に間違いやすいポイントのひとつとして、転送元のディレクトリ名の末尾に `/` をつけるかつけないかで挙動が異なるという点があります。間違い防止には、`-n`（`--dry-run`）オプションや `-v`（`--verbose`）オプションが有益です。
