## About Read Logger Tools

Read Logger Tools は動物搭載型の行動記録計（データロガー）で取得したデータをIgor proで読み取るためのパッケージです。
行動記録計では複数のデータが、バラバラのサンプリング間隔で記録されるので、手動でいちいち読み込むのは大変です。
このパッケージは、各データロガーで得られた生データの読み取りからデータの時刻設定までを半自動的に行います。

## インストール方法

gitを使い慣れている方は`git clone`でレポジトリを複製してください。
ReadLoggerToolsはこれからアップデートする予定もあるので、gitでのご利用を推奨します。
gitがわからない方は、直接ファイルを下のリンクからダウンロードしてください。
使用時は、解凍してから使ってください。

次にパソコンの中でUser Proceduresを開いてください。

- Windowsならば、`C:¥Users¥<user>¥Documents¥WaveMetrics`
- Macならば`/Applications/Igor Pro 8 Folder/User Procedures/`

に存在することが多いようです（フォルダの場所の詳細については、Igorのマニュアルを参照してください）。
User Proceduresを開いたら、ReadLoggerToolsをフォルダごと置いてください。
これでインストールは完了です。

[![](icons/icons_dl.png)](https://github.com/Takaaki-K-Abe/ReadLoggerTools/archive/refs/tags/V0.0.zip)

### 起動の仕方

Igor Proを起動したらProcedure windowを開き、以下のコマンドを書き込んでください。

```{c}
#include "ReadLoggerTools"
```

無事にコンパイルされると、メニューにRead Logger Dataが表示されます。


## 対応ロガー

現在対応しているロガーは以下の通りです。
基本的には製作者が触ったことのあるロガーとなっていますが、製作者 (t.abe.hpa[at]gmail.com) に相談いただければ、順次追加していく予定です。
リンクをクリックすると使い方が表示されます。

### Little Leonardo

- W-Series
- [ECG-series](https://takaaki-k-abe.github.io/ReadLoggerTools/Read_LL_ECG.html)

<!-- - ORI-Seires -->

<!-- ### Lotek

- LAT-Series
  - LAT2910 -->
