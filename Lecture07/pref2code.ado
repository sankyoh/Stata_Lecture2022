*! version 1.0.0  23feb2023
program define pref2code
syntax varname [if] [in] , GENerate(string) [replace]

/* display "5 `varlist'"
display "6 `generate'"
display "7 `replace'"
display "8 `in'"
display "9 `if'" */

if ("`if'" == ""){
	local if "if 1"
}

if ("`replace'" == "replace"){
	qui cap drop `generate'
}


qui {
gen `generate' = .

replace `generate' =  1 `in' `if' & (regexm(`varlist', "北海道") | regexm(`varlist', "[H/h]okkaido"))

replace `generate' =  2 `in' `if' & (regexm(`varlist', "青森") | regexm(`varlist', "[A/a]omori"))
replace `generate' =  3 `in' `if' & (regexm(`varlist', "岩手") | regexm(`varlist', "[I/i]wate"))
replace `generate' =  4 `in' `if' & (regexm(`varlist', "宮城") | regexm(`varlist', "[M/m]iyagi"))
replace `generate' =  5 `in' `if' & (regexm(`varlist', "秋田") | regexm(`varlist', "[A/a]kita"))
replace `generate' =  6 `in' `if' & (regexm(`varlist', "山形") | regexm(`varlist', "[Y/y]amagata"))
replace `generate' =  7 `in' `if' & (regexm(`varlist', "福島") | regexm(`varlist', "[F/f/H/h]ukushima"))

replace `generate' =  8 `in' `if' & (regexm(`varlist', "茨城") | regexm(`varlist', "[I/i]baragi"))
replace `generate' =  9 `in' `if' & (regexm(`varlist', "栃木") | regexm(`varlist', "[T/t]ochigi"))
replace `generate' = 10 `in' `if' & (regexm(`varlist', "群馬") | regexm(`varlist', "[G/g]unma"))
replace `generate' = 11 `in' `if' & (regexm(`varlist', "埼玉") | regexm(`varlist', "[S/s]aitama"))
replace `generate' = 12 `in' `if' & (regexm(`varlist', "千葉") | regexm(`varlist', "[C/c]hiba"))
replace `generate' = 13 `in' `if' & (regexm(`varlist', "東京") | regexm(`varlist', "[T/t]okyo"))
replace `generate' = 14 `in' `if' & (regexm(`varlist', "神奈川") | regexm(`varlist', "[K/k]anagawa"))

replace `generate' = 15 `in' `if' & (regexm(`varlist', "新潟") | regexm(`varlist', "[N/n]iigata"))
replace `generate' = 16 `in' `if' & (regexm(`varlist', "富山") | regexm(`varlist', "[T/t]oyama"))
replace `generate' = 17 `in' `if' & (regexm(`varlist', "石川") | regexm(`varlist', "[I/i]shikawa"))
replace `generate' = 18 `in' `if' & (regexm(`varlist', "福井") | regexm(`varlist', "[F/f/H/h]ukui"))
replace `generate' = 19 `in' `if' & (regexm(`varlist', "山梨") | regexm(`varlist', "[Y/y]amanashi"))
replace `generate' = 20 `in' `if' & (regexm(`varlist', "長野") | regexm(`varlist', "[N/n]agano"))

replace `generate' = 21 `in' `if' & (regexm(`varlist', "岐阜") | regexm(`varlist', "[G/g]i[f/h]u"))
replace `generate' = 22 `in' `if' & (regexm(`varlist', "静岡") | regexm(`varlist', "[S/s]hizuoka"))
replace `generate' = 23 `in' `if' & (regexm(`varlist', "愛知") | regexm(`varlist', "[A/a]ichi"))
replace `generate' = 24 `in' `if' & (regexm(`varlist', "三重") | regexm(`varlist', "[M/m]ie"))

replace `generate' = 25 `in' `if' & (regexm(`varlist', "滋賀") | regexm(`varlist', "[S/s]higa"))
replace `generate' = 26 `in' `if' & (regexm(`varlist', "京都") | regexm(`varlist', "[K/k]yoto"))
replace `generate' = 27 `in' `if' & (regexm(`varlist', "大阪") | regexm(`varlist', "[O/o]saka"))
replace `generate' = 28 `in' `if' & (regexm(`varlist', "兵庫") | regexm(`varlist', "[H/h]yogo"))
replace `generate' = 29 `in' `if' & (regexm(`varlist', "奈良") | regexm(`varlist', "[N/n]ara"))
replace `generate' = 30 `in' `if' & (regexm(`varlist', "和歌山") | regexm(`varlist', "[W/w]akayama"))

replace `generate' = 31 `in' `if' & (regexm(`varlist', "鳥取") | regexm(`varlist', "[T/t]ottori"))
replace `generate' = 32 `in' `if' & (regexm(`varlist', "島根") | regexm(`varlist', "[S/s]himane"))
replace `generate' = 33 `in' `if' & (regexm(`varlist', "岡山") | regexm(`varlist', "[O/o]kayama"))
replace `generate' = 34 `in' `if' & (regexm(`varlist', "広島") | regexm(`varlist', "[H/h]iroshima]"))
replace `generate' = 35 `in' `if' & (regexm(`varlist', "山口") | regexm(`varlist', "[Y/y]amaguchi"))

replace `generate' = 36 `in' `if' & (regexm(`varlist', "徳島") | regexm(`varlist', "[T/t]okushima"))
replace `generate' = 37 `in' `if' & (regexm(`varlist', "香川") | regexm(`varlist', "[K/k]agawa"))
replace `generate' = 38 `in' `if' & (regexm(`varlist', "愛媛") | regexm(`varlist', "[E/e]hime"))
replace `generate' = 39 `in' `if' & (regexm(`varlist', "高知") | regexm(`varlist', "[K/k]ochi"))

replace `generate' = 40 `in' `if' & (regexm(`varlist', "福岡") | regexm(`varlist', "[F/f/H/h]ukuoka"))
replace `generate' = 41 `in' `if' & (regexm(`varlist', "佐賀") | regexm(`varlist', "[S/s]aga"))
replace `generate' = 42 `in' `if' & (regexm(`varlist', "長崎") | regexm(`varlist', "[N/n]agasaki"))
replace `generate' = 43 `in' `if' & (regexm(`varlist', "熊本") | regexm(`varlist', "[K/k]umamoto"))
replace `generate' = 44 `in' `if' & (regexm(`varlist', "大分") | regexm(`varlist', "[O/o]ita"))
replace `generate' = 45 `in' `if' & (regexm(`varlist', "宮崎") | regexm(`varlist', "[M/m]iyazaki"))
replace `generate' = 46 `in' `if' & (regexm(`varlist', "鹿児島") | regexm(`varlist', "[K/k]agoshima"))

replace `generate' = 47 `in' `if' & (regexm(`varlist', "沖縄") | regexm(`varlist', "[O/o]kinawa"))

}

labmask `generate', value(`varlist')

end