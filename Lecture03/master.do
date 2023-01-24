/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
*
***** ***** ***** ***** ***** ***** ****/

* データセット読込み整理
do crDataset

* 記述統計
do anDesStat

* 粗解析モデル
do anRegress model_1

* 調整モデル
do anRegress model_2

* 2モデル（粗解析モデルと調整モデル）の結果をExcel書出し
do wtRegtoExcel 2