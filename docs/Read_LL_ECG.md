## ECG-series, Little Leonardo

### 動作確認機種

- ECG-400DT
- ECG-400DTG

### ECG-Series

1. `#include Read_LL_ECG_Series`あるいは、直接`Read_LL_ECG_Series.ipf`を読み込む。
正常に読み込まれるとMenuに`Read Logger Data`が表示される。
2. `Read Logger Data > ECG-Series`を選択するとパネルが開かれ、以下の4つのパラメータの入力画面が開かれる
  - Start Date: ロガーの記録開始日
  - Start Time: ロガーの記録開始時刻
  - ECG Sampling Frequency  (Hz): ECGのサンプリング周波数
  - Accel Sampling Frequency (Hz): 加速度のサンプリング周波数
3. 適宜パラメータを入力後、`Start to read ECG logger`をクリックするとファイルを選択画面が開かれる。
Little LeronardoのECG-Seriesはロガーデータが複数のテキストファイルに分割されているので、読み込むデータを全て選択する。

