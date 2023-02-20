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