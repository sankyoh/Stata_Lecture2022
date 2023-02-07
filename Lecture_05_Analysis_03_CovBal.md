# 今日のゴール
* 共変量バランスを効率よく行いたい。

# 今日の目的
* Lecture4のdoファイルに追記する。

# Lecture4のdo fileから変更したいところ
共変量バランスについて、`ローカルマクロconf_var1`を共変量として計算しても結果はよかったですが、更に上を目指そうと思います。

そのためには、別候補`ローカルマクロconf_var2`（2乗項や交互作用項も含む）によるIPTWの算出と検証をできるだけ手軽に行いたいと思います。

## master.doファイルの修正

anPScalcを一旦コメントアウトして、anPSexploreを作成することにしました。

このanPSexploreで（できるだけ）「最良」の傾向スコアを探索したいと思います。


```stata
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
do anPSexplore

* 傾向スコア・IPTW算出
do anPScalc

* 傾向スコア・IPTWの評価
do anPSeval

* 粗解析モデル
do anRegress model_1

* 調整モデル
do anRegress model_2

* IPTWモデル // 追記箇所
do anIPTW

* 3モデル（粗解析モデルと調整モデルとIPTWモデル）の結果をExcel書出し 編集箇所
do wtRegtoExcel 3 // 3に書き換えた。
```

# （できるだけ）最良の傾向スコア探索のためのdoファイル作成
## 「最良」の定義
まず、どのような状態を「最良」と呼ぶのかを決めておかないと、探索のしようがありません。

今回は下記の様に定義したいと思います。
* 全ての共変量で、分散比が0.8~1.25の範囲である。
* 全ての共変量で、標準化差の絶対値が0.1未満である。
* 共変量の標準化差（絶対値）の平均値がより小さい。

## anPSexploreの全体像

最良のPSの計算方法を（出来るだけ楽に）探索するためのdo fileを作成します。（プロジェクトファイルの`03. PS`グループに新規ファイルを追加してください）

試行錯誤の過程が完全に自動化すれば、美味しいのですが、そこまでは難しいです。

ここでは下記のセクションに分けています。
* 候補の設定
* 探索ループ
* ループ内部：傾向スコアとIPTW計算
* ループ内部：共変量バランス算出
* ループ内部：「最良」の基準チェック


```stata
/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
* Propensity Score Explore
*
***** ***** ***** ***** ***** ***** ****/
version 17

* データ読み込み
use nhefs_01, clear

* 候補の設定
local kouho=2
local conf_var1  sex age race i.education smokeintensity smokeyrs i.exercise i.active wt71
local conf_var2 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71


* 探索
forvalues i=1/`kouho' {
	* 傾向スコア計算
	qui xi:logit qsmk `conf_var`i''
	predict ps`i', pr

	* 重み計算
	gen iptw`i' = cond(qsmk==1, 1/ps`i', 1/(1-ps`i')) if !missing(ps`i')

  * 共変量バランス
	qui covbal qsmk sex age race smokeintensity smokeyrs wt71 _I*, wt(iptw`i') abs

	* 結果表示
	display _newline(1) "conf_var`i'"
	matlist r(table) 
	
	* absolute SMDチェック
	forvalues x=1/`r(varcnt)'{
		local t=r(table)[`x',7]
		if(`t'<-0.1 | 0.1<`t'){
			display "ASD is violated - `x' variable"
		}
		else {
			// display "ASD check is OK - `x' variable"
		}
	}

	* VRチェック
	forvalues x=1/`r(varcnt)'{
		local t=r(table)[`x',8]
		if(`t'<0.8 | 1.25<`t'){
			display "VR is violated - `x' variable"
		}
		else {
			// display "VR check is OK - `x' variable"
		}
	}

	* 標準化差の絶対値の平均値を表示
	di "mean ASD = `r(masd)'"
}
```

セクション別に内容を見ていきます。

### 候補の設定
このセクションでは、共変量バランスをとるための傾向スコア（IPTW）計算に用いるための変数設定を行っています。

`ローカルマクロconf_var1`では、2乗項や交互作用項を含んでいません。一方で、`ローカルマクロconf_var2`では、2乗項や交互作用項も含んでいます。

これらの候補を`localコマンド`を用いて先に決めておきます。なお、変数の種類自体は変わっていません。変数の種類の選択方法は、DAGなどの事前知識に基づくべきで、データドリブンに用いるべきではないからです。

また、候補の個数もここで`ローカルマクロkouho`として設定しています。

### ループ

評価ループは次のような構造になっています。今回は、`ローカルマクロkouho`で設定した候補数が2つなので2回ループを行っています。

```
forvalues i=1/`kouho' {
  傾向スコアとIPTW計算
  共変量バランス算出
  「最良」の基準チェック
}
```

`forvalues`のループ変数として`i`を使っています。1周目のループでは`i=1`で、2周目のループでは`i=2`となります。

### 傾向スコアとIPTW計算
前回と同様に傾向スコアをロジスティック回帰分析で求めています。

```
* 傾向スコア計算
qui xi:logit qsmk `conf_var`i''
predict ps`i', pr

* 重み計算
gen iptw`i' = cond(qsmk==1, 1/ps`i', 1/(1-ps`i')) if !missing(ps`i')
```

ロジスティック回帰分析の前に`qui`といれています。これは`quiet`の略で、「結果出力をしない」というプレフィックスコマンドです。

ロジスティック回帰分析の説明変数に、ローカルマクロの入れ子`` `conf_var`i'' ``を用いています。

1周目では`i=1`ですので、この部分は`` `conf_var1' ``と展開されます。

2周目では`i=2`ですので、この部分は`` `conf_var2' ``と展開されます。

これによって、最初の「候補の設定」で設定した共変量での計算が行えます。

次に`predictコマンド`で、条件付け確率（＝傾向スコア）を算出していますが、作成される変数を`` ps`i' ``とすることで、1周目と2周目で異なる変数名で作成することができます。

重み計算でも同様で、作成する変数名を`` iptw`i' ``として、1周目と2周目で異なる変数名で変数を作成しています。

同じ変数名を作成しようとするとエラーになるし、できれば残しておきたいため、このような措置をとっています。

### 共変量バランスチェック（＝標準化差と分散比の算出）
`外部コマンドcovbal`を用いて、共変量バランス（標準化差、分散比）います。

```
* 共変量バランス
qui covbal qsmk sex age race smokeintensity smokeyrs wt71 _I*, wt(iptw`i') abs
```

前回での使用とほぼかわりありませんが、`absオプション`をつけています。このオプションは標準化差を絶対値で表示するというオプションです。正と負が入り交じった状態で平均値を算出すると、算出値が小さくなるため、絶対値の算出を行っています。

結果を見るだけでも良いのですが、この後で使うので、Stored resultsを利用します。`covbalコマンド`では、いくつかのStored resultsがあります。return listで確認できます。

|Stored results名| 意味 |形式|
|-|-|-|
|r(varcnt)|評価した共変量の個数|スカラー|
|r(mvr)|分散比の平均値|スカラー|
|r(masd)|標準化差の平均値|スカラー|
|r(table)|結果の表|マトリクス|

次の「最良」の基準チェックのために、これらを活用します。

### 「最良」の基準チェック
まず、2つのチェックを行っています。つまり、（1）標準化差の絶対値が0.1未満であること、（2）分散比が0.8～1.25の範囲内であること、です。これらは基本的に同じ構造をとっています。

標準化差の絶対値のチェック方法から見ていきます。

```
* absolute SMDチェック
forvalues x=1/`r(varcnt)'{
  local t=r(table)[`x',7]
  if(0.1<`t'){
    display "ASD is violated - `x' variable"
  }
  else {
    // display "ASD check is OK - `x' variable"
  }
}
```

ループ内ループになっています。

`forvalues`のループの設定が`` x=1/`r(varcnt)' ``となっています。

r(varcnt)には、covbalによって作られるStored resultの1つです。バランスを評価した変数の個数が格納されます。covbalコマンドの今回はダミー変数を含めると14変数ありますので、この部分はStataによって` x=1/14 ` と解釈されます。

次の行にある`` local t=r(table)[`x',7] ``では、標準化差の絶対値を`ローカルマクロt`に代入するというコマンドになっています。

`r(table)`は、14変数×8項目の結果表となっています。このうち、7列目が標準化差（の絶対値）で、8列目が分散比になっています。

ループにつかっている`ローカルマクロx`は、1から14までの値をとりますので、`` r(table)[`x', 7] ``は、下記の様な意味になっています。

|`x'の値=周回| r(table)[`x', 7] |意味|
|-|-|-|
|1|r(table)[1,7]|変数sexの標準化差|
|2|r(table)[2,7]|変数ageの標準化差|
|3|r(table)[3,7]|変数raceの標準化差|
|...|...|...|
|14|r(table)[14,7]|変数_Iactive_2の標準化差|

その後の`if`と`else`で分岐を行っています。

最初の`` if(0.1<`t') ``の条件に当てはまれば、最初の`{  }`内の動作を実行し、それでなければ`else`の中括弧部分の動作を実行します。

ifの{}では条件をクリアしなかったことが表示されます。また、今回はelse部の動作はコメントアウトしています（ほとんどの変数で条件をクリアしているので、表示が煩雑になるため）。

分散比のチェックに関するコードもほぼ同様のコードになっています。

最後に、標準化差の絶対値の平均値を表示しています。

```
* 標準化差の絶対値の平均値を表示
di "mean ASD = `r(masd)'"
```

`r(masd)`は、covbalのStored resultsで標準化差の絶対値の平均値が格納されています。

なお、多分バグかヘルプファイルの記載ミスだと思いますが、covbalでabsオプションを付けずにr(masd)を表示させると、標準化差の平均値（絶対値の平均値ではなく）が表示されます。

## このコードで「最良」をどう探すか？
「候補の設定」部分に良さそうなものを追記します。

例えば、conf_var3を追記し、kouho=3としました。

conv_var3では、`c.age#c.wt71 c.age#active c.age#exercise c.age#education`の3つの交互作用項を追加しました。

```
* 候補の設定
local kouho=3
local conf_var1  sex age race i.education smokeintensity smokeyrs i.exercise i.active wt71
local conf_var2 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71
local conf_var3 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education　
```

候補の設定部**のみ**を変更して、anPSexploreを実行すると、下記の様になり、conf_var3が最良のようです。

|conf_var| SMD条件 | VR条件 | ASMDの絶対値 |
|-|-|-|-|
|1|クリア|クリアならず|0.0189|
|2|クリア|クリア|0.0140|
|3|クリア|クリア|0.0113|

さらに良い物は無いかと考え、人種と教育の交互作用項`race#education`を追加しました。

```
local kouho=4
// 中略
local conf_var4 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education race#education
```

これで、実行します。

|conf_var| SMD条件 | VR条件 | ASMDの絶対値 |
|-|-|-|-|
|1|クリア|クリアならず|0.0189|
|2|クリア|クリア|0.0140|
|3|クリア|クリア|0.0113|
|4|クリア|クリア|0.0136|

しかし、やや悪くなってしまったようです。

いろいろ試行錯誤してみると、下記で0.0112になります。

```
local conf_var5 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education race#c.wt7 
```

|conf_var| SMD条件 | VR条件 | ASMDの絶対値 |
|-|-|-|-|
|1|クリア|クリアならず|0.0189|
|2|クリア|クリア|0.0140|
|3|クリア|クリア|0.0113|
|4|クリア|クリア|0.0136|
|5|クリア|クリア|0.0112|

なので、この方針で進めたいと思います。

# 探索した結果をanPScalcに記載する。
anPSexploreで良い感じの計算方法が見つかったので、anPScalcのlocal

anPScalsの編集箇所（冒頭箇所）
```
* データ読み込み
use nhefs_01, clear

local conf_var1 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education race#c.wt7 
```

この部を変更して、anPScalcを実行すれば、（たぶん）「最良」の傾向スコアが算出できます。

また、これに合わせて、master.doでは、anPSexploreをコメントアウトします。傾向スコアの探索を行わなければ、このdoファイルの役目はおわりです。

```
* 傾向スコア探索 // 追記箇所
// do anPSexplore
```

# 再度、anPSeval.doを実行する。
## 共変量バランスの評価・図示

共変量バランス（標準化差）

![lec4_bal_smd](https://user-images.githubusercontent.com/67684585/215559420-f4315d29-f37f-4e1b-bb3e-42fa0bd50a79.png)

共変量バランス（分散比）

![lec4_bal_vr](https://user-images.githubusercontent.com/67684585/215559607-192aac17-d797-4b5f-b7b9-c27bc0785301.png)
