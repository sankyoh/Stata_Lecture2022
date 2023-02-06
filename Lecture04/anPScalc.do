/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
* Propensity Score Calculation
*
***** ***** ***** ***** ***** ***** ****/
version 17

* データ読み込み
use nhefs_01, clear

local conf_var1  sex age race i.education smokeintensity smokeyrs i.exercise i.active wt71
local conf_var2 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71


* Conditional probability of Quit smoking
xi:logit qsmk `conf_var2'
predict ps, pr

* Unconditional probability of Quit smoking
logit qsmk
predict uncp, pr

* 重み計算
gen unwt = 1
gen iptw = cond(qsmk==1, 1/ps, 1/(1-ps)) if !missing(ps)
gen stdw = cond(qsmk==1, uncp/ps, (1-uncp)/(1-ps)) if !missing(ps, uncp) // 参考・今回は使わない
gen ovlw = cond(qsmk==1, 1-ps, ps) if !missing(ps) // 参考・今回は使わない

label variable ps "Propensity Score"
label variable uncp "Unconditional Probability"
label variable unwt "=1 constant"
label variable iptw "Inverse Probability Treatement Weight"
label variable stdw "Standardized Weight" // 参考・今回は使わない
label variable ovlw "Overlap Weight" // 参考・今回は使わない

* 新しいデータセットとしてセーブ
compress
label data "nhefs_01 + PS & IPTW"
save nhefs_02, replace