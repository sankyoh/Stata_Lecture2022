/**** ***** ***** ***** ***** ***** *****
*
* Result of Regression Matrix 
*     to Excel table.
*
***** ***** ***** ***** ***** ***** ****/
version 17

matrix result = model_1
forvalues x=2/`1' {
   matrix rowjoin result = result model_`x'
}

putexcel set Result_table2.xlsx, replace
putexcel A1 = "model"
putexcel B1 = "Coef"
putexcel C1 = "95%CI"
putexcel E1 = "p-value"
putexcel A2 = matrix(result), nformat(#.000) rownames 
putexcel save