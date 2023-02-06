/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
* Descriptive Statistics
*
***** ***** ***** ***** ***** ***** ****/
version 17

use nhefs_01, clear

// ssc install table1

table1, by(qsmk) ///
   vars(sex cat \ age contn \ race cat \ education cat \ wt71 contn \ smokeintensity conts \ smokeyrs conts \ active cat \ exercise cat)

table1, by(qsmk) ///
   vars(sex cat \ age contn \ race cat \ education cat \ wt71 contn \ smokeintensity conts \ smokeyrs conts \ active cat \ exercise cat) ///
   format(%9.2f) saving(Result_table1.xlsx, replace)
