/**** ***** ***** ***** ***** ***** *****
*
* Stata Seminar 2022, NHEFS analysis 01
* Propensity Score Evaluation
*
***** ***** ***** ***** ***** ***** ****/
version 17

* データ読み込み
use nhefs_02, clear

* 外部コマンド
// ssc install schemepack, replace // イケてる感じのグラフテーマ集
// ssc install bihist, replace     // 上下に伸びるヒストグラム（ヒストグラムの比較に便利）
// ssc install covbal, replace        // 変数バランスの確認
// net install grc1leg.pkg, replace from(http://www.stata.com/users/vwiggins/)  // グラフの結合
// net install gr0034.pkg, replace from(http://www.stata-journal.com/software/sj8-2/) // labmask

* 事前設定
set scheme white_tableau
local wt unwt iptw // stdw ovlw


* 図示による傾向スコアの分布
foreach w of local wt {
	bihist ps [pw=`w'], by(qsmk) percent width(0.05) start(0) ///
		tw( xtitle(Propensity Score) ytitle(Percent) ///
			legend(row(2) order(2 1) label(1 "No Quit") label(2 "Quit"))) ///
		name(`w'_hist, replace)
}

grc1leg unwt_hist iptw_hist,  ycommon position(3) name(comb_hist, replace)

* 交絡要因のバランスについて確認
foreach w of local wt {
	covbal qsmk sex age race smokeintensity smokeyrs wt71 _I*, wt(`w') saving(bal_`w', replace)
}

* 交絡要因のバランスを図示
capture frame change default
capture frame drop covbal
frame create covbal
frame covbal {
	use bal_unwt, clear
	gen odr = _N - _n + 1
	keep odr varname stdiff varratio
	rename stdiff stdiff_unwt
	rename varratio varratio_unwt
	
	merge 1:1 varname using bal_iptw
	assert _merge == 3 // _merge==3以外があれば、何かおかしいのでassertで止める
	drop _merge tr_mean tr_var tr_skew con_mean con_var con_skew
	rename stdiff stdiff_iptw
	rename varratio varratio_iptw
	sort odr
	
	labmask odr, value(varname)
	
	/* カラーパレット設定
	colorpalette hcl, select(1 6 9) nograph
	local unadj `r(p1)'
	local adj `r(p3)'
	local zero `r(p2)'*/
	
	* 標準化差のグラフ
	twoway ///
		scatter odr stdiff_unwt, ylabel(14(1)1, valuelabel) mcolor("`unadj'") || ///
		scatter odr stdiff_iptw, ylabel(14(1)1, valuelabel) mcolor("`adj'") || ///
		function y= 0.1, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y=-0.1, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y=0   , horizontal range(0 14) lcolor("`zero'")  ///
		legend(order(1 "Unadjusted" 2 "Adjusted")) ///
		xtitle("Standardized Mean Difrences") title(Covariate Balance) ///
		name(bal_smd, replace)
	
	* 分散比のグラフ
	twoway ///
		scatter odr varratio_unwt, ylabel(14(1)1, valuelabel) mcolor("`unadj'") || ///
		scatter odr varratio_iptw, ylabel(14(1)1, valuelabel) mcolor("`adj'")|| ///
		function y=1.25, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y= 0.8, horizontal range(0 14) lcolor(gs8) lpattern(shortdash) || ///
		function y=   1, horizontal range(0 14) lcolor("`zero'")  ///
		legend(order(1 "Unadjusted" 2 "Adjusted")) ///
		xscale(log) xlabel(0.7 0.8(0.2)1.0 1.25) xscale(extend) ///
		xtitle("Variance Ratio, log-scale") title(Covariate Balance) ///
		name(bal_vr, replace)
}