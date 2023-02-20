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
`anIPTW`にも下記の特徴をもたせます。
1. 1つのdoファイルで複数のモデルの解析が可能
2. どのモデルを使うかは、コマンドの引数（`` `1' ``）によって決まる。
3. アウトプットは、マトリクスに格納される。

## 1つのdoファイルで複数のモデルの解析が可能
ここで「複数のモデル」としていますが、重み付けの方法には、複数ありますので、1つのdoファイルでそれらに対応できるようにしたいと思います。

特に、ATEを推定するときに利用できる重みとしては、IPTW以外に「Stbilized weight」というものがあります。こちらの方がunsturated modelでは信頼区間が狭くなるという特徴がありますので、一般に有用です。

実は、こっそりと計算していました。`anPScalc`を確認していただくと、変数`stbw`が計算されています。これが「Stabilized weight」です。

今回は、変数iptwと変数stbwの両方で利用出来るようなdoファイルを作ります。

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


---------
## 補遺）重み付けしたときのvceオプションについて

重み付け解析で利用している重み（IPTWなど）は、真値ではなく推測値ですので、バラツキを考慮する必要があります。そのため、バラツキをロバスト推定するようにStataに指示する必要があります。

これを実測しているのが、`vce(robust)`です。

しかし、vce(roubust)を外して実行しても、結果はかわりません。

これは、`[pw=iptw]`のように`pw`を指定すると、Stataは自動で`vce(robust)`を行うためです。
