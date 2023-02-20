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
local kouho=5
local conf_var1  sex age race i.education smokeintensity smokeyrs i.exercise i.active wt71

local conf_var2 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71

local conf_var3 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education

local conf_var4 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education race#education

local conf_var5 sex race c.age##c.age i.education c.smokeintensity##c.smokeintensity ///
c.smokeyrs##c.smokeyrs i.exercise i.active c.wt71##c.wt71 c.age#c.wt71 c.age#active ///
c.age#exercise c.age#education race#c.wt7 

* 評価
forvalues i=1/`kouho' {
	* Conditional probability of Quit smoking
	qui xi:logit qsmk `conf_var`i''
	predict ps`i', pr

	* 重み計算
	gen iptw`i' = cond(qsmk==1, 1/ps`i', 1/(1-ps`i')) if !missing(ps`i')


	qui covbal qsmk sex age race smokeintensity smokeyrs wt71 _I*, wt(iptw`i') abs


	* 結果表示
	display _newline(1) "conf_var`i'"
	mat list r(table) 
	
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