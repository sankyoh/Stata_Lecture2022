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

* 粗解析モデル
do anRegress model_1

* 調整モデル
do anRegress model_2

* IPTWモデル
do anIPTW model_3 // 追記箇所

* Stabilized Weight
do anIPTW model_4 // 追記箇所

* 3モデル（粗解析モデルと調整モデルとIPTWモデル）の結果をExcel書出し 編集箇所
do wtRegtoExcel 4 // 編集箇所 引数をモデル個数（4個）に書き換えた。