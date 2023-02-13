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
anPSexploreで良い感じの計算方法が見つかったので、anPScalcのlocalに最良だった計算方法をコピペします。

anPScalsの編集箇所（冒頭箇所）
```
* データ読み込み
use nhefs_01, clear

local conf_var1 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education race#c.wt7 
```

この部を変更して、anPScalcを実行すれば、（現状の探索の範囲において[^1]）「最良」の傾向スコアが算出できます。

また、これに合わせて、master.doでは、anPSexploreをコメントアウトします。傾向スコアの探索を行わなければ、このdoファイルの役目はおわりです。`master.do`ファイルからは、コメントアウトしておきます。

```
* 傾向スコア探索 // 追記箇所
// do anPSexplore
```

# 再度、anPSeval.doを実行する。

最良の方法で傾向スコアを計算しなおしたので、`anPSval.do`で傾向スコア（によって計算されたIPTW）について評価をし直します。

## 傾向スコアの図示（再）
```
local wt unwt iptw

* 図示による傾向スコアの分布
foreach w of local wt {
	bihist ps [pw=`w'], by(qsmk) percent width(0.05) start(0) ///
		tw( xtitle(Propensity Score) ytitle(Percent) ///
			legend(row(2) order(2 1) label(1 "No Quit") label(2 "Quit"))) ///
		name(`w'_hist, replace)
}

grc1leg unwt_hist iptw_hist,  ycommon position(3) name(comb_hist, replace)
```

ローカルマクロ`wt`として、`unwt iptw`が定義されていますので、`foreach`ループの1周目では`w=unwt`として実行され、2周目では`w=iptw`として実行されます。

つまり、「重み付けなし」と「IPTWによる重み付け」でグラフを描画します。

## 共変量バランスの評価・図示
### 表による評価（再）
今度は、個々の変数について評価を行います。
```
* 交絡要因のバランスについて確認
foreach w of local wt {
	covbal qsmk sex age race smokeintensity smokeyrs wt71 _I*, wt(`w') saving(bal_`w', replace)
}
```
外部コマンド`covbal`において、`saving`というオプションを付けています。このオプションをつけると、結果として得られた表を`dtaファイル`形式で書き出します。

このコマンドを実行すると、カレントディレクトリ（プロジェクトファイルがあるフォルダ）に、`bal_unwt.dta`と`bal_iptw.dta`というStataデータ形式のファイルが生成されます。

この内容が、bal_unwt.dtaとして保存されています。
![image](https://user-images.githubusercontent.com/67684585/218557045-40260d15-5ec4-47b1-95cb-56d193d6c10b.png)

こちらの重み付けを行った際の内容は、bal_iptw.dtaとして保存されています。
![image](https://user-images.githubusercontent.com/67684585/218557216-99456f11-fd22-4771-9be0-153fb11473f1.png)

ここでわざわざ、データとして保存したのは、この次の作図を円滑に行うためです。

### 共変量バランスの図示
共変量バランスの図示には、ドットを利用したプロットが有用です。

Rでは比較的簡単に作図できますが、Stataには専用のコマンドが（現状では）用意されていませんので、工夫しながら描画します。

完成予想図は下記の様になっています。

#### 共変量バランス（標準化差）

![lec4_bal_smd](https://user-images.githubusercontent.com/67684585/215559420-f4315d29-f37f-4e1b-bb3e-42fa0bd50a79.png)

#### 共変量バランス（分散比）

![lec4_bal_vr](https://user-images.githubusercontent.com/67684585/215559607-192aac17-d797-4b5f-b7b9-c27bc0785301.png)

#### 作図コマンド

```
* 交絡要因のバランスを図示
capture frame change default
capture frame drop covbal
frame create covbal
frame covbal {
	use bal_unwt, clear
	gen odr = _N - _n + 1
	keep odr varname stdiff varratio
	rename stdiff stdiff_unwt
	rename varratio varratio_unwt
	
	merge 1:1 varname using bal_iptw
	assert _merge == 3 // _merge==3以外があれば、何かおかしいのでassertで止める
	drop _merge tr_mean tr_var tr_skew con_mean con_var con_skew
	rename stdiff stdiff_iptw
	rename varratio varratio_iptw
	sort odr
	
	labmask odr, value(varname)
	
	/* カラーパレット設定
	colorpalette hcl, select(1 6 9) nograph
	local unadj `r(p1)'
	local adj `r(p3)'
	local zero `r(p2)'*/
	
	* 標準化差のグラフ
	twoway ///
		scatter odr stdiff_unwt, ylabel(14(1)1, valuelabel) mcolor("`unadj'") || ///
		scatter odr stdiff_iptw, ylabel(14(1)1, valuelabel) mcolor("`adj'") || ///
		function y= 0.1, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y=-0.1, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y=0   , horizontal range(0 14) lcolor("`zero'")  ///
		legend(order(1 "Unadjusted" 2 "Adjusted")) ///
		xtitle("Standardized Mean Difrences") title(Covariate Balance) ///
		name(bal_smd, replace)
	
	* 分散比のグラフ
	twoway ///
		scatter odr varratio_unwt, ylabel(14(1)1, valuelabel) mcolor("`unadj'") || ///
		scatter odr varratio_iptw, ylabel(14(1)1, valuelabel) mcolor("`adj'")|| ///
		function y=1.25, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y= 0.8, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y=   1, horizontal range(0 14) lcolor("`zero'")  ///
		legend(order(1 "Unadjusted" 2 "Adjusted")) ///
		xscale(log) xlabel(0.7 0.8 1.0 1.25 1.5) xscale(extend) ///
		xtitle("Variance Ratio, log-scale") title(Covariate Balance) ///
		name(bal_vr, replace)
}
```

##### frameの利用
ここでまず、`frame`コマンドを利用しています。

```
capture frame change default
capture frame drop covbal
frame create covbal
frame covbal {
    様々なコマンド
}
```

Stataでは、複数のデータを（仮想的に？）同時に扱う事ができるようになりました。これを「フレーム」を切り替えて使います。`frame change フレーム名`というコマンドで、指定したフレームを利用できる状態になります。

最初から使っているフレームは`default`という名前が付いています。まず、何らかの操作によって、違うフレームを使っているとdoファイルが想定通りに動かないことがありますので、`capture frame change default`というコマンドで、最初から使っているフレームに戻るようにします。

次に、`covbal`というフレームを作るのですが、既に作っていると、エラーが起きますので、一旦削除を行います。削除を行うのは`frame drop フレーム名`です。ここでは`capture frame drop covbal`としています。このように頭に`capture`をつけることで、covbalフレームが存在しないというエラーが発生しても、Stataは先に進んでくれます。

そして、ようやく新しいフレームを作ります。`frame create フレーム名`で新しいフレームを作ることができます。ここでは`frame create covbal`としています。

新しく作ったcovbalフレームを操作するには、2通りの方法があります。

1. `frame change covbal`を実行する
2. `frame covbal { 操作 }`といいうように中括弧を使う。

今回は、後者を利用しています。

#### 描画準備

covbalフレームで操作を開始します。

最初は描画しやすくなるように、データを操作します。

```
use bal_unwt, clear
gen odr = _N - _n + 1
keep odr varname stdiff varratio
rename stdiff stdiff_unwt
rename varratio varratio_unwt

merge 1:1 varname using bal_iptw
assert _merge == 3 // _merge==3以外があれば、何かおかしいのでassertで止める
drop _merge tr_mean tr_var tr_skew con_mean con_var con_skew
rename stdiff stdiff_iptw
rename varratio varratio_iptw
sort odr

labmask odr, value(varname)
```

最初に、重み付けなしにおける標準化差・分散比が格納されたデータセットを読み込みます。`use bal_unwt, clear`。

![image](https://user-images.githubusercontent.com/67684585/218561904-cbbf9055-2236-476d-b9fb-d56472e31f03.png)

そのあと、変数`odr`を作成します。これは、変数の表示順をしていするための変数です。

```
gen odr = _N - _n + 1
```

Stataにおいて、`_N`は、観察数（症例数）を表します。今回では`_N=14`です。`_n`は、各観察番号を表します。`sex`の行であえば、`_n=1`ですし、`age`の行であれば`_n=2`になります。

このため、`odr = _N - _n + 1`という計算式は、上から順に14, 13, 12, 11, 10, ...2, 1という値になります。

![image](https://user-images.githubusercontent.com/67684585/218562676-02564ec7-f023-49cf-a600-38cd471752a1.png)

そして、必要な変数以外を削除します。`keep odr varname stdiff varratio`

また、この後でbal_iptwとマージするので、変数名をunwt由来のものだと分かるように変更しておきます。
```
rename stdiff stdiff_unwt
rename varratio varratio_unwt
```

ここまでできた所です。

![image](https://user-images.githubusercontent.com/67684585/218563070-1aa7c4b3-894a-45e2-91bf-4e3f3605931c.png)

次に、iptwで重み付けた結果（標準化差・分散比）を結合させます。

```
merge 1:1 varname using bal_iptw
assert _merge == 3
```

mergeが実行されると、`_merge`という変数が作成され、過不足なく結合すると全ての行で`_merge=3`となります。

今回は、14行の結合がぴったりとできるはずなので、`_merge=3`以外の値はないはずです。そのチェックを行うために、`assert _merge=3`というコマンドを書いています。このコマンドは、条件に当てはまらない行が1つでもあると、エラーを吐き出します。（doファイルはそこで止ります）

`assert`コマンドでマージがうまくできたことを確認したので、先に進みます。

```
drop _merge tr_mean tr_var tr_skew con_mean con_var con_skew
rename stdiff stdiff_iptw
rename varratio varratio_iptw
sort odr
```

不要な変数を削除し、標準化差・分散比についてiptw由来であることが分かるように変数名を変更します。

あと、odr順に並び替えを行いました。

![image](https://user-images.githubusercontent.com/67684585/218564317-0c7227fa-33ae-4ead-b4da-78b3ee435bab.png)

これで、odrを縦軸とし、標準化差や分散比を横軸とする散布図を描けば、望む物が得られます。

ただ、完成図のように、縦軸を数字ではなく変数名にしたいと思います。しかし、varname変数はstr型ですので、グラフには使えません。

そこで、int変数odrに、str変数varrnameの値をラベルとして貼り付けます。

このためのコマンドがlabmaskです。

```
labmask odr, value(varname)
```

変数odrにvarnameの値と同じ名称を持つラベルが貼られた所です。
![image](https://user-images.githubusercontent.com/67684585/218565189-8fd33756-6a39-4cc0-98af-3fcb24659a48.png)

list, nolとすると、変数odrが依然として数値をもっていることがわかります。

#### 描画（標準化差）

```
twoway ///
    scatter odr stdiff_unwt, ylabel(14(1)1, valuelabel) mcolor("`unadj'") || ///
    scatter odr stdiff_iptw, ylabel(14(1)1, valuelabel) mcolor("`adj'") || ///
    function y= 0.1, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
    function y=-0.1, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
    function y=0   , horizontal range(0 14) lcolor("`zero'")  ///
    legend(order(1 "Unadjusted" 2 "Adjusted")) ///
    xtitle("Standardized Mean Difrences") title(Covariate Balance) ///
    name(bal_smd, replace)
```

`twoway`による描画コマンドです。

最初2つのscatterでは、重み付けなしの場合の散布図とIPTW重み付けの時の散布図を描いています。

ylabel(14(1)1, valuelabel)というオプションにより、変数順を指定し、軸にodrの値を表示するのでは無く、odrの値ラベルを表示する、という指定になっています。

mcolorでドットの色を指定していますが、特段の指定がなければ、標準色が適応されます。

3行目～5行目では、縦線を描画しています。真ん中（x=0）の線と基準範囲となる線（x=-0.1とx=0.1）です。

最後の3行では、legendやタイトルなどを指定し、グラフの名称を付けて終了しています。


#### 描画（分散比）

```
twoway ///
    scatter odr varratio_unwt, ylabel(14(1)1, valuelabel) mcolor("`unadj'") || ///
    scatter odr varratio_iptw, ylabel(14(1)1, valuelabel) mcolor("`adj'")|| ///
    function y=1.25, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
    function y= 0.8, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
    function y=   1, horizontal range(0 14) lcolor("`zero'")  ///
    legend(order(1 "Unadjusted" 2 "Adjusted")) ///
    xscale(log) xlabel(0.7 0.8 1.0 1.25 1.5) xscale(extend) ///
    xtitle("Variance Ratio, log-scale") title(Covariate Balance) ///
    name(bal_vr, replace)
```

基本的には、標準化差のグラフと同様ですが、相違点として、xscale(log)を付けて、横軸を対数軸にしています。これは、「比」であるためです。

[^1]:候補の変数に対して全検索をかければ、真の最良が見つけられますが、そこまでしなくても良いかも。
