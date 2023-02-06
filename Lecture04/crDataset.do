/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
* Data Import, Cleaning, and Labeling
*
***** ***** ***** ***** ***** ***** ****/
version 17

use nhefs, clear

keep if !missing(wt82_71) // アウトカム欠損がない
keep if !missing(qsmk)    // 曝露欠損がない

keep seqn qsmk wt82_71 sex age race education smokeintensity smokeyrs exercise active wt71 // 必要な変数以外削除
order seqn qsmk wt82_71

* ラベル
label define qsmk 0 "no quit" 1 "quit"
label values qsmk qsmk

label define sex 0 "male" 1 "female"
label values sex sex

label define race 0 "white" 1 "black/other"
label values race race

label define education 1 "8th grade or less" 2 "HS dropout" 3 "HS" 4 "College dropout" 5 "College or more"
label values education education

label define exercise  0 "much exercise" 1 "moderate exercise" 2 "little or no exercise"
label values exercise exercise 

label define active 0 "very active" 1 "moderate active" 2 "inactive"
label values active active

compress 
label data "230124"
save nhefs_01.dta, replace