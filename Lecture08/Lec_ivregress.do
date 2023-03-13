use nhefs.dta, clear
drop if price82 == .
drop if wt82_71 == .

gen highprice = (price82 > 1.5) 
label define price 0 "low" 1 "highW
label values highprice price

* 分子の計算
ttest wt82_71, by(highprice) rev

* 分母の計算
tab highprice qsmk, row

* 割り算
di 0.1502887/(0.2578 - 0.1951)

* 専用コマンド
ivregress 2sls wt82_71 (qsmk = hiprice)

* カットオフ値を色々かえて試す
drop highprice*
local x = 1
forvalues y = 1.5(0.1)1.9 {
  display "y=`y'"
	gen highprice`x' = (price82 > `y' & price82 < .)
	tab highprice`x' qsmk, row
	ivregress 2sls wt82_71 (qsmk = highprice`x')
	local x = `x' + 1
}

* 連続量のまま
ivregress 2sls wt82_71 (qsmk=price82)