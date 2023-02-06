# 今日のゴール
* 共変量バランスを効率よく行いたい。

# 今日の目的
* Lecture4のdoファイルに追記する。

# Lecture4のdo fileから変更したいところ
共変量バランスについて、`conf_var1`を共変量として計算しても結果はよかったですが、更に上を目指そうと思います。

そのためには、別候補`conf_var2`（2乗項や交互作用項も含む）によるIPTWの算出と検証をできるだけ手軽に行いたいと思います。

## master.doファイルの修正

anPScalcを一旦コメントアウトして、anPSexploreを作成することにしました。

このanPSexploreで（できるだけ）最良の傾向スコアを探索したいと思います。


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


* 傾向スコア・IPTW算出
// do anPScalc

* 傾向スコア探索 // 追記箇所
do anPSexplore

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
どのような状態を「最良」と呼ぶのかを決めておかないと、探索のしようがありません。

今回は、下記の様に定義したいと思います。
* 全ての共変量で、分散比が0.8~1.25の範囲である。
* 全ての共変量で、標準化差の絶対値が0.1未満である。
* 共変量の標準化差（絶対値）の平均値がより小さい。

## anPSexploreの全体像

最良のPSの計算方法を（出来るだけ楽に）探索するためのdo fileを作成します。

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
forvalues i=1/2 {
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
		local t :display r(table)[`x',7]
		if(`t'<-0.1 | 0.1<`t'){
			display "ASD is violated - `x' variable"
		}
		else {
			// display "ASD check is OK - `x' variable"
		}
	}

	* VRチェック
	forvalues x=1/`r(varcnt)'{
		local t :display r(table)[`x',8]
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

### 候補の設定
このセクションでは、共変量バランスをとるための傾向スコア（IPTW）計算に用いるための変数設定を行っています。

conf_var1では、2乗項や交互作用項を含んでいません。

conf_var2では、2乗項や交互作用項も含んでいます。

これらの候補をlocalコマンドを用いて先に決めておきます。なお、変数の種類自体は変わっていません。変数の種類の選択方法は、DAGなどの事前知識に基づくべきで、データベースに用いるべきではないからです。

また、候補の個数もここで`ローカルマクロkouho`として設定しています。

### ループ

評価ループはこのような構造になっています。今回は候補数が2つなので、2回ループを行っています。

```
forvalues i=1/`kouho' {
  傾向スコアとIPTW計算
  共変量バランス算出
  「最良」の基準チェック
}
```

ループ変数として`i`を使っています。1周目のループでは`i=1`で、2周目のループでは`i=2`となります。

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

### 共変量バランスチェック
外部コマンドcovbalを用いています。

```
* 共変量バランス
qui covbal qsmk sex age race smokeintensity smokeyrs wt71 _I*, wt(iptw`i') abs
```

前回での使用とほぼかわりありませんが、absオプションをつけています。このオプションは、標準化差を絶対値で表示するというオプションです。

このcovbalコマンドでは、いくつかのStored resultsがあります。return listで確認できます。

|Stored results名| 意味 |形式|
|-|-|-|
|r(varcnt)|評価した共変量の個数|スカラー|
|r(mvr)|分散比の平均値|スカラー|
|r(masd)|標準化差の平均値|スカラー|
|r(table)|結果の表|マトリクス|

次の「最良」の基準チェックのために、これらを活用します。

### 「最良」の基準チェック
まず、2つのチェックを行っています。つまり、（1）標準化差の絶対値が0.1未満であること、（2）分散比が0.8～1.25の範囲内であること、です。

```
* absolute SMDチェック
forvalues x=1/`r(varcnt)'{
  local t :display r(table)[`x',7]
  if(0.1<`t'){
    display "ASD is violated - `x' variable"
  }
  else {
    // display "ASD check is OK - `x' variable"
  }
}
```

