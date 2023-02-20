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