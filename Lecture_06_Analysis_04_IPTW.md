# 今日のゴール
* IPTW解析を完了する。
* 粗解析の結果、多変量解析の結果、IPTWの結果を並べてExcelに書き出す。

# 今日の目的
* IPTW解析を行うためのdoファイル（anIPTW）を作成する。
* anRegressを確認し、それと類似した形式でanIPTWを作成する。

# anRegress再び
Lecture_05までで、良い感じの重みを計算することに成功しました。

この重みを用いて、禁煙(`qsmk`）が体重変化（`wt82_71`）に与える影響を推定します（＝ATEの計算）。

一旦、anRegressを確認します。

```
version 17

use nhefs_01, clear

local model_1 
local model_2 i.sex age i.race i.education smokeintensity smokeyrs i.exercise i.active wt71

regress wt82_71 qsmk ``1''

* esttabを使って、回帰係数・信頼区間・p値を取得
// net install st0085_2
est store `1'
qui esttab `1', ci 
matrix `1' = r(coefs)[1,1..4]

* 行と列の名前を設定
matrix coleq   `1' = regress
matrix rowname `1' = `1'
```

このdoファイルで特徴なのは、下記の点です。
* 1つのdoファイルで複数のモデルの解析が可能
* どのモデルを使うかは、コマンドの引数（`` `1' ``）によって決まる。
* アウトプットは、マトリクスに格納される。

この点を継承し、`anIPTW`を作成します。

# anIPTWの作成
プロジェクトの`04. Inf Stat`に新規ファイルとして追加します。

![image](https://user-images.githubusercontent.com/67684585/220187508-ae160673-746c-4ede-85a4-cfabbb47a821.png)

`anIPTW`にも下記の特徴をもたせます。
1. 1つのdoファイルで複数のモデルの解析が可能
2. どのモデルを使うかは、コマンドの引数（`` `1' ``）によって決まる。
3. アウトプットは、マトリクスに格納される。

## 1つのdoファイルで複数のモデルの解析が可能
ここで「複数のモデル」としていますが、重み付けの方法には、複数ありますので、1つのdoファイルでそれらに対応できるようにしたいと思います。

特に、ATEを推定するときに利用できる重みとしては、IPTW以外に「Stbilized weight」というものがあります。こちらの方がunsturated modelでは信頼区間が狭くなるという特徴がありますので、一般に有用です。

実は、こっそりと計算していました。`anPScalc`を確認していただくと、変数`stbw`が計算されています。これが「Stabilized weight」です。

今回は、変数ptwと変数stbwの両方で利用出来るようなdoファイルを作ります。

## どのモデルを使うかは、コマンドの引数（`` `1' ``）によって決まる。
つまり、コマンドの引数（`` `1' ``）を用いて、利用する重みを指定するという方法を考えます。

## アウトプットは、マトリクスに格納される。
anRegressのアウトプットと同じ形のマトリクスにしておけば、あとで便利です。

## anIPTWの中身

下記のようなdoファイルで完成です。
これは、anRegressの一部を書き換えたのみです。

```
/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
* ATE estimate by Weighting 
*
***** ***** ***** ***** ***** ***** ****/
version 17

use nhefs_02, clear

local model_3 iptw
local model_4 stbw

regress wt82_71 qsmk [pw=``1''], vce(robust)

* esttabを使って、回帰係数・信頼区間・p値を取得
// net install st0085_2, from(http://www.stata-journal.com/software/sj14-2) replace
est store `1'
qui esttab `1', ci 
matrix `1' = r(coefs)[1,1..4]

* 行と列の名前を設定
matrix coleq   `1' = regress
matrix rowname `1' = `1'
```

書き換えた場所を確認していきます。

まず、読み込むデータを変更しています。anRegressでは、傾向スコアや重みを計算する前でのデータセット（`nhefs_01`）を読み込みましたが、今回は`nfefs_02`に変更されています。

つぎに、`local`の指定が変わっています。

```
local model_3 iptw
local model_4 stbw
```

model_3でiptwを重みとし、model_4でstbwを重みとする計画です。

最後に、`regress`コマンドが重み付き解析に変更されています。

```
regress wt82_71 qsmk [pw=``1''], vce(robust)
```

重みの指定を``` [pw=``1''] ```で行っています。

あとは、anRegressと変わっていません。

# master.doの修正
では、anIPTWを実行し、結果をExcelに格納するために、master.doファイルも編集します。

```
/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
*
***** ***** ***** ***** ***** ***** ****/

* データセット読込み整理
do crDataset

* 記述統計
do anDesStat

* 傾向スコア探索
// do anPSexplore

* 傾向スコア・IPTW算出
do anPScalc


* 傾向スコア・IPTWの評価
do anPSeval

* 粗解析モデル
do anRegress model_1

* 調整モデル
do anRegress model_2

* IPTWモデル
do anIPTW model_3 // 追記箇所

* Stabilized Weight
do anIPTW model_4 // 追記箇所

* 3モデル（粗解析モデルと調整モデルとIPTWモデル）の結果をExcel書出し
do wtRegtoExcel 4 // 編集箇所 引数をモデル個数（4個）に書き換えた。
```

追記や編集を行ったのは、（コメントを除くと）3行です。

まず、`do anIPTW model_3`と`do anIPTW model_4`で、重み付き解析を実施します。

その結果をExcelに書き出すdoファイル（`wtRegtoExcel`）の引数をモデル個数である`4`に書き換えました。

これで、`master.do`を実行すると、作業フォルダに`Result_table2.xlsx`が生成されます。

# さらに目指したいこと
ここまでで、だいぶん汎用的になったように思います。

しかし、モデルを変更するときに編集する箇所が分かれていることが不十分です。

モデルを編集するときには、下記のローカルマクロを編集する必要があり、wtRegtoExcelの引数を変更する必要があります。
* local model_1
* local model_2
* local model_3
* local model_4
* wtRegtoExcelの引数

これらは、解析の根幹にかかわることなので、完全自動化することはできません。

しかし、それぞれ違うdoファイル中にあるため、編集を忘れてしまう可能性があり、doファイルの管理上よくありません。

編集しなければならない項目を1箇所に集めるという方法は、解決方法の1つです。

## maste.doの編集

下記のようにmaster.doを編集しました。

```
/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
*
***** ***** ***** ***** ***** ***** ****/


* データセット読込み整理
do crDataset

* 記述統計
do anDesStat

* 傾向スコア探索 // 追記箇所
// do anPSexplore

* 傾向スコア・IPTW算出
do anPScalc

* 傾向スコア・IPTWの評価
do anPSeval

* ===== ===== ===== ===== モデル情報 記載箇所 ===== ===== ===== =====
global model_1 
global model_2 i.sex age i.race i.education smokeintensity smokeyrs i.exercise i.active wt71
global model_3 iptw
global model_4 stbw
local  num_model 4
* ===== ===== ===== ===== モデル情報 記載箇所 ===== ===== ===== =====

* 粗解析モデル
do anRegress model_1

* 調整モデル
do anRegress model_2

* IPTWモデル
do anIPTW model_3 

* Stabilized Weight
do anIPTW model_4

* 3モデル（粗解析モデルと調整モデルとIPTWモデル）の結果をExcel書出し
do wtRegtoExcel `num_model'
```

モデルの指定をmaster.doの中で固めて行いました。

ただし、localで指定すると、master.do以外では使えませんので、global指定にしています。また、モデル個数はlocalでnum_modelとして指定しています。

## anRegressの変数
master.doでモデルの指定を行ったので、anRegress内ではモデル指定が不要になりました。

localを削除し、regressコマンドのみ変更しています。

```
version 17

use nhefs_01, clear

regress wt82_71 qsmk ${`1'}

* esttabを使って、回帰係数・信頼区間・p値を取得
// net install st0085_2, from(http://www.stata-journal.com/software/sj14-2) replace
est store `1'
qui esttab `1', ci 
matrix `1' = r(coefs)[1,1..4]

* 行と列の名前を設定
matrix coleq   `1' = regress
matrix rowname `1' = `1'
```

## anIPTWの編集
こちらも同様です。localを削除し、regressコマンドのみ変更しています。

```
version 17

use nhefs_02, clear

regress wt82_71 qsmk [pw=${`1'}], vce(robust)

* esttabを使って、回帰係数・信頼区間・p値を取得
// net install st0085_2, from(http://www.stata-journal.com/software/sj14-2) replace
est store `1'
qui esttab `1', ci 
matrix `1' = r(coefs)[1,1..4]

* 行と列の名前を設定
matrix coleq   `1' = regress
matrix rowname `1' = `1'
```

モデル情報を記載する箇所をmaster.doの1箇所にまとめたことによって、メインテナンス性が高まりました。


---------
## 補遺）重み付けしたときのvceオプションについて

重み付け解析で利用している重み（IPTWなど）は、真値ではなく推測値ですので、バラツキを考慮する必要があります。そのため、バラツキをロバスト推定するようにStataに指示する必要があります。

これを実測しているのが、`vce(robust)`です。

しかし、vce(roubust)を外して実行しても、結果はかわりません。

これは、`[pw=iptw]`のように`pw`を指定すると、Stataは自動で`vce(robust)`を行うためです。

## 補遺）曝露変数が3カテゴリ以上ある場合

曝露変数が3カテゴリ以上ある場合に、今回のdoファイルのセットを使うと3つの問題が生じます（解決は可能です）。

1. 結果をマトリクスとして取得するときに、結果がうまく取得できない。
2. ロジスティック回帰分析では、傾向スコアを算出できない。
3. 重み付けによる共変量バランスを評価できない。

1点目は、マトリクスの取得方法を変更する必要があります。

例えば、曝露変数が3カテゴリ（0=低, 1=中, 2=高）であった場合、`i.`を用いてダミー変数化しますので「**低**を対照とした**中**の回帰係数」、「**低**を対照とした**高**の回帰係数」が算出されます。

曝露変数が二値変数であれば、下記のようなコマンドで取得していました。これは「1行目の1列目～4列目を取得する」という意味になっています。
```
matrix `1' = r(coefs)[1,1..4]
```

曝露変数が3カテゴリあれば、下記のようなコマンドになります。これは「2行目～3行目の1列目～4列目を取得する」という意味になっています。

```
matrix `1' = r(coefs)[2..3,1..4]
```

1行目を取得しないのは、上記例でいえば「**低**の回帰係数」が1列目に格納されているためです。ダミー変数化したときの対照は、回帰係数にゼロが格納されています。

2点目は、ロジスティック回帰分析を多項ロジスティック回帰分析に変更することで対応可能です。確率の計算も`predict`コマンドで可能です。

3点目は、2カテゴリ比較を3回行うことで可能です。あまり見ませんが…


