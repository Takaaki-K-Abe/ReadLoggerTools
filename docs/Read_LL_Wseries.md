## W-series, Little Leonardo

### 動作確認機種

- W-PD3GT
- W-PDT
- W-3MPD3GT

### 使用方法

1. `Read Logger Data > W-Series`を選択するとパネルが開かれます。
2. `Auto`あるいは`Manual`を選択します。
3. `Manual`を選択時はロガーの記録開始日時を入力してください。
4. `Start to read logger`をクリックすると読み込み画面が開かれるので、読み込むデータを選択してください (複数選択可)。

### データの読み込みに関する説明

公開している関数ではデータとデータのヘッダ部部分をそれぞれ読み取り、データをwaveへと整形しています。
W-seriesのロガーからダウンロードしたデータは以下に示すようなヘッダーを持っています。

```
"File name:", "C:\Program Files (x86)\LoggerTools V341\DATA\PD3GT_11766_202110Kitakami_1st.obj"
"Channel:", "Acceleration-X"
"Units:", "count"
"Total record:",  1
"Record No.:",  1
"Start location:", 0
"Start date:", 2021/10/10
"Start time:", 10:26:13
"Data size:", 3769180
"Interval(Sec):", 0.1250000
```

公開中の関数ではここに書かれているヘッダー部分のうち、

- "Channnel:" (データ種類)
- "Start date:"　(記録開始年月日)
- "Start time:" (記録開始時刻)
- "Interval(Sec):" (記録間隔)

を読み取っています。
**Auto mode**では、waveの時刻・サンプリング間隔の設定を、ヘッダー部分の情報に基づいて読み込み、**Manual mode**では、パネルに入力した値に基づいて読み込んでいます。
データ管理の観点から、できる限りヘッダー部分に時刻情報を記入しておくのがよいかと製作者は考えています。
