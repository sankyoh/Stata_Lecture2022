# 今日のゴール
* pref2code.adoを作成する。

# 今日の目的
* adoファイルの作り方を理解する。

# 都道府県（文字列）をコード化したい。
公的データなどには、都道府県が文字列として格納されています。そのまま使っても良いのですが、解析に用いる際には、数値化しておかないと上手く解析することができません。

そのため、コード化を行う必要があります。

## encodeによるコード化の問題点

Stataには、コード化するためのコマンドとして`encode`が用意されています。

このGithubのLecture07フォルダに格納されている`Prefecture_data01.xlsx`で試してみたいと思います。

```
import excel "Prefecture_data01.xlsx", clear first
codebook pref

encode pref, gen(pref_code)
```

都道府県名は、`pref`に格納されていますので、`encode`コマンドでコード化します。コード化された変数として`pref_code`を指定しています。

実際にうまくできたか確認しようと思います。

```
list pref pref_code in 1/10
```

![image](https://user-images.githubusercontent.com/67684585/221647601-f3ca656a-57d3-4a79-b46e-a0f6e70d537a.png)

うまくいっているようです。

しかし、ラベル無しで表示させると、あまり状況はよくありません。

```
list pref pref_code in 1/10, nol
```

![image](https://user-images.githubusercontent.com/67684585/221647820-3698878e-00d8-4509-8ef5-8779a6c146db.png)

北海道が「4」としてコード化しています。`encode`は文字コード順にコード化します（三重県が「1」）。これは、わが国の都道府県番号とは全く異なっていて、扱いにくい数値です。

この問題を解決するためのadoファイルを作りたいと思います。

## pref2code.ado・最初のバージョン

まずは、動けば良いというadoファイルを作ります。

コードは長いですが、うち47行は、各都道府県のコード化です。

これをadoファイルとして、ワーキングディレクトリにセーブします。

* **doファイルで保存すると動作しません!!!!**
* **ワーキングディレクトリ以外に保存すると動作しません!!!!**

```
program define pref2code
gen `2' = .

replace `2' = 1 if regexm(`1', "北海道") | regexm(`1', "[H/h]okkaido")

replace `2' = 2 if regexm(`1', "青森") | regexm(`1', "[A/a]omori")
replace `2' = 3 if regexm(`1', "岩手") | regexm(`1', "[I/i]wate")
replace `2' = 4 if regexm(`1', "宮城") | regexm(`1', "[M/m]iyagi")
replace `2' = 5 if regexm(`1', "秋田") | regexm(`1', "[A/a]kita")
replace `2' = 6 if regexm(`1', "山形") | regexm(`1', "[Y/y]amagata")
replace `2' = 7 if regexm(`1', "福島") | regexm(`1', "[F/f/H/h]ukushima")

replace `2' = 8 if regexm(`1', "茨城") | regexm(`1', "[I/i]baragi")
replace `2' = 9 if regexm(`1', "栃木") | regexm(`1', "[T/t]ochigi")
replace `2' = 10 if regexm(`1', "群馬") | regexm(`1', "[G/g]unma")
replace `2' = 11 if regexm(`1', "埼玉") | regexm(`1', "[S/s]aitama")
replace `2' = 12 if regexm(`1', "千葉") | regexm(`1', "[C/c]hiba")
replace `2' = 13 if regexm(`1', "東京") | regexm(`1', "[T/t]okyo")
replace `2' = 14 if regexm(`1', "神奈川") | regexm(`1', "[K/k]anagawa")

replace `2' = 15 if regexm(`1', "新潟") | regexm(`1', "[N/n]iigata")
replace `2' = 16 if regexm(`1', "富山") | regexm(`1', "[T/t]oyama")
replace `2' = 17 if regexm(`1', "石川") | regexm(`1', "[I/i]shikawa")
replace `2' = 18 if regexm(`1', "福井") | regexm(`1', "[F/f/H/h]ukui")
replace `2' = 19 if regexm(`1', "山梨") | regexm(`1', "[Y/y]amanashi")
replace `2' = 20 if regexm(`1', "長野") | regexm(`1', "[N/n]agano")

replace `2' = 21 if regexm(`1', "岐阜") | regexm(`1', "[G/g]i[f/h]u")
replace `2' = 22 if regexm(`1', "静岡") | regexm(`1', "[S/s]hizuoka")
replace `2' = 23 if regexm(`1', "愛知") | regexm(`1', "[A/a]ichi")
replace `2' = 24 if regexm(`1', "三重") | regexm(`1', "[M/m]ie")

replace `2' = 25 if regexm(`1', "滋賀") | regexm(`1', "[S/s]higa")
replace `2' = 26 if regexm(`1', "京都") | regexm(`1', "[K/k]yoto")
replace `2' = 27 if regexm(`1', "大阪") | regexm(`1', "[O/o]saka")
replace `2' = 28 if regexm(`1', "兵庫") | regexm(`1', "[H/h]yogo")
replace `2' = 29 if regexm(`1', "奈良") | regexm(`1', "[N/n]ara")
replace `2' = 30 if regexm(`1', "和歌山") | regexm(`1', "[W/w]akayama")

replace `2' = 31 if regexm(`1', "鳥取") | regexm(`1', "[T/t]ottori")
replace `2' = 32 if regexm(`1', "島根") | regexm(`1', "[S/s]himane")
replace `2' = 33 if regexm(`1', "岡山") | regexm(`1', "[O/o]kayama")
replace `2' = 34 if regexm(`1', "広島") | regexm(`1', "[H/h]iroshima]")
replace `2' = 35 if regexm(`1', "山口") | regexm(`1', "[Y/y]amaguchi")

replace `2' = 36 if regexm(`1', "徳島") | regexm(`1', "[T/t]okushima")
replace `2' = 37 if regexm(`1', "香川") | regexm(`1', "[K/k]agawa")
replace `2' = 38 if regexm(`1', "愛媛") | regexm(`1', "[E/e]hime")
replace `2' = 39 if regexm(`1', "高知") | regexm(`1', "[K/k]ochi")

replace `2' = 40 if regexm(`1', "福岡") | regexm(`1', "[F/f/H/h]ukuoka")
replace `2' = 41 if regexm(`1', "佐賀") | regexm(`1', "[S/s]aga")
replace `2' = 42 if regexm(`1', "長崎") | regexm(`1', "[N/n]agasaki")
replace `2' = 43 if regexm(`1', "熊本") | regexm(`1', "[K/k]umamoto")
replace `2' = 44 if regexm(`1', "大分") | regexm(`1', "[O/o]ita")
replace `2' = 45 if regexm(`1', "宮崎") | regexm(`1', "[M/m]iyazaki")
replace `2' = 46 if regexm(`1', "鹿児島") | regexm(`1', "[K/k]agoshima")

replace `2' = 47 if regexm(`1', "沖縄") | regexm(`1', "[O/o]kinawa")

end
```

このadoファイルは、引数を2つもち、1個目に文字列で都道府県が格納されている変数を指定し、2個目で新たに作る変数を指定しています。

最初に新たに作るコード化する予定の変数を`gen`で定義しています。
```
gen `2' = .
```

あとは、ひたすら`replace`で条件に当てはまる場合に値を代入していきます。
```
replace `2' = 33 if regexm(`1', "岡山") | regexm(`1', "[O/o]kayama")
```

`if`以下が成立すれば、新たに作る変数に「33」を代入します。

ここで利用している`regexm(s, re)`関数は、`s`に`re`が含まれていたら（より正確には「正規表現にマッチしたら」）「1」の値を返し、含まれていなければ、「0」を返す関数です。

例えば、下記はそれぞれ、「1」と「0」が表示されます。
```
display regexm("Okayama", "kayama")
display regexm("Kagawa", "kayama")
```

`` regexm(`1', "岡山") ``は、「岡山」が含まれていたら「1」になります。

regexm(`1', "[O/o]kayama") ``は、「Okayama」または「okayama」が含まれていたら「1」になります。

ここで使った`[O/o]`は、「O」と[o」のどちらでも良いという意味になります。

それでは、ちょっと`pref2code.ado`を動かしてみましょう。

```
import excel "Prefecture_data01.xlsx", clear firs
pref2code pref pref_new

list pref pref_new in 1/10
```

![image](https://user-images.githubusercontent.com/67684585/221657171-5a850885-07fd-49a2-8046-d9a807f82ef2.png)

期待していたコードが割り振られました。

## pref2code.ado・ラベルを貼り付けたい

取りあえず、動く様になりましたが、新たに作った変数には、ラベルが貼られていません。

そのため、ラベルを貼りつけたいと思います。

`labmask`を用いると簡単に実行できます。

さきほどのコードに下記を追加します。（`end`のすぐ上に）

```
labmask `2', value(`1')
end
```

labmaskコマンドは外部コマンドなので、予めインストールしてください。

では、実行します。

```
import excel "Prefecture_data01.xlsx", clear first
pref2code pref pref_new

list pref pref_new in 1/10
```

下記の様になったかと思います。

![image](https://user-images.githubusercontent.com/67684585/221657171-5a850885-07fd-49a2-8046-d9a807f82ef2.png)

`labmask`コマンドで新たにラベルを貼ったはずなのに、反映されていません。

これは、adoファイルを作成するときに注意してほしいポイントです。

adoファイルを修正して、保存しても、稼働中のStataには影響しません。

一旦、稼働中のStataから修正前の`pref2code`を削除する必要があります。

コマンドラインにて下記を実行してください。

```
program drop pref2code
```

その後で、次を実行してください。
```
import excel "Prefecture_data01.xlsx", clear first
pref2code pref pref_new

list pref pref_new in 1/10
```

![image](https://user-images.githubusercontent.com/67684585/221659159-2886aa3b-6d54-4396-a2e3-b27aede3e832.png)

ラベルが割り振られたようです。

また、変数`pref_new`は数値であることは、`des pref pref_new`で確認できます。

## pref2code.ado・静かにさせる。

このコマンドではgenが1個に、replaceが47個あるので、実行画面に48回の結果が表示され、やや邪魔です。

この表示を止めるためには、`qui`を使います。

```
qui {
gen `2' = .

replace `2' = 1 if regexm(`1', "北海道") | regexm(`1', "[H/h]okkaido")

// （中略）

replace `2' = 47 if regexm(`1', "沖縄") | regexm(`1', "[O/o]kinawa")

}
```

このようなという表記をすると、中括弧内の処理は、Stataからのレスポンスがなくなります。

実行時の表示が不要（邪魔）なときには、`qui`で制御すると良い感じのadoファイルになります。

```
qui { 
  処理
}
```

## pref2code.ado・文法に則った記載

このまま完成でも良いのですが、このコマンドはStataの一般文法に則っていません。

`encode`を参考に文法の指定を行いたいと思います。

下記が`encode`の文法です。

```
encode varname [if] [in] , generate(newvar) [label(name) noextend]
```

これを再現したいと思います。

```
pref2code varname [if] [in] , generate(newvar) [replace]
```

最後の部分だけ、少し変更しました。

encodeの最後の部分は、どのようなラベルを利用するか？というオプションです

`pref2code`では、都道府県以外のラベルを貼ることは想定していないので、削除しました。

かわりに、replaceオプションをつけました。

generateオプションで、コード化した新しい変数をつくりますが、それが既にあったときにencodeはエラーになります。

常々、上書きオプションがあれば良いな、と思っていましたので、自作コマンドでは上書きオプションを作る事にします。

このような文法を反映させたいと思います。

文法は`syntax`コマンドで指定します。

全体は下記の様になっています。

```
*! version 1.0.0  23feb2023
program define pref2code
syntax varname [if] [in] , GENerate(string) [replace]

display "5 `varlist'"
display "6 `generate'"
display "7 `replace'"
display "8 `in'"
display "9 `if'"

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
replace `generate' = 10 `in' `if' & (regexm(`varlist', "群馬") | regexm(`varlist', "[G/g]unma")))
replace `generate' = 11 `in' `if' & (regexm(`varlist', "埼玉") | regexm(`varlist', "[S/s]aitama"))
replace `generate' = 12 `in' `if' & (regexm(`varlist', "千葉") | regexm(`varlist', "[C/c]hiba"))
replace `generate' = 13 `in' `if' & (regexm(`varlist', "東京") | regexm(`varlist', "[T/t]okyo"))
replace `generate' = 14 `in' `if' & (regexm(`varlist', "神奈川") | regexm(`varlist', "[K/k]anagawa"))

replace `generate' = 15 `in' `if' & (regexm(`varlist', "新潟") | regexm(`varlist', "[N/n]iigata"))
replace `generate' = 16 `in' `if' & (regexm(`varlist', "富山") | regexm(`varlist', "[T/t]oyama")))
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
replace `generate' = 27 `in' `if' & (regexm(`varlist', "大阪") | regexm(`varlist', "[O/o]saka")))
replace `generate' = 28 `in' `if' & (regexm(`varlist', "兵庫") | regexm(`varlist', "[H/h]yogo"))
replace `generate' = 29 `in' `if' & (regexm(`varlist', "奈良") | regexm(`varlist', "[N/n]ara"))
replace `generate' = 30 `in' `if' & (regexm(`varlist', "和歌山") | regexm(`varlist', "[W/w]akayama"))

replace `generate' = 31 `in' `if' & (regexm(`varlist', "鳥取") | regexm(`varlist', "[T/t]ottori"))
replace `generate' = 32 `in' `if' & (regexm(`varlist', "島根") | regexm(`varlist', "[S/s]himane")))
replace `generate' = 33 `in' `if' & (regexm(`varlist', "岡山") | regexm(`varlist', "[O/o]kayama"))
replace `generate' = 34 `in' `if' & (regexm(`varlist', "広島") | regexm(`varlist', "[H/h]iroshima]"))
replace `generate' = 35 `in' `if' & (regexm(`varlist', "山口") | regexm(`varlist', "[Y/y]amaguchi"))

replace `generate' = 36 `in' `if' & (regexm(`varlist', "徳島") | regexm(`varlist', "[T/t]okushima"))
replace `generate' = 37 `in' `if' & (regexm(`varlist', "香川") | regexm(`varlist', "[K/k]agawa"))
replace `generate' = 38 `in' `if' & (regexm(`varlist', "愛媛") | regexm(`varlist', "[E/e]hime")))
replace `generate' = 39 `in' `if' & (regexm(`varlist', "高知") | regexm(`varlist', "[K/k]ochi"))

replace `generate' = 40 `in' `if' & (regexm(`varlist', "福岡") | regexm(`varlist', "[F/f/H/h]ukuoka"))
replace `generate' = 41 `in' `if' & (regexm(`varlist', "佐賀") | regexm(`varlist', "[S/s]aga"))
replace `generate' = 42 `in' `if' & (regexm(`varlist', "長崎") | regexm(`varlist', "[N/n]agasaki"))
replace `generate' = 43 `in' `if' & (regexm(`varlist', "熊本") | regexm(`varlist', "[K/k]umamoto")))
replace `generate' = 44 `in' `if' & (regexm(`varlist', "大分") | regexm(`varlist', "[O/o]ita"))
replace `generate' = 45 `in' `if' & (regexm(`varlist', "宮崎") | regexm(`varlist', "[M/m]iyazaki"))
replace `generate' = 46 `in' `if' & (regexm(`varlist', "鹿児島") | regexm(`varlist', "[K/k]agoshima"))

replace `generate' = 47 `in' `if' & (regexm(`varlist', "沖縄") | regexm(`varlist', "[O/o]kinawa"))

}

labmask `generate', value(`varlist')

end
```

### syntaxコマンドの利用

まず、最初の部分から確認します。

```
syntax varname [if] [in] , GENerate(string) [replace]
```

`syntax`コマンドで文法をしていしています。

pref2codeは、下記のような文法を持つと指定されています。
* コマンドのすぐ後に変数1つのみ（`varname`）を持つこと。
* if節が使えること（省略可能）
* in節が使えること（省略可能）
* generateオプションが必須であること
* generateオプションの括弧内に文字列`string`を記載する事
* generateはgenと省略可能（大文字部分）
* replaceオプションが使えること（省略可能）

`syntax`コマンドで指定した分布通りに書かれると、プログラム内のローカルマクロになります。
* varname部分 ⇒ `` ロカールマクロ`varlist' ``
* if節 ⇒ `` ローカルマクロ`if' ``
* in節 ⇒ `` ローカルマクロ`in' ``
* オプションgenerate ⇒ `` ローカルマクロ`generate' ``
* オプションreplace ⇒ `` ローカルマクロ`replace' ``

プログラム内でこれらが取得されていることを確認したいと思います。

```
display "5 `varlist'"
display "6 `generate'"
display "7 `replace'"
display "8 `in'"
display "9 `if'"
```

とりあえず、この部分の確認のために、下記をうごかします。

```
cap program drop pref2code
pref2code pref in 1/40 if Y19M01 > 1766, gen(pref_code) replace
```

![image](https://user-images.githubusercontent.com/67684585/221670603-a7b03389-3fa1-4f10-aed7-93db248ed2bd.png)

コマンドに入力した情報が、プログラム内のローカルマクロとして取得されました。

このローカルマクロを用いて内部処理を行います。

まず、`replace`オプションについて処理を行います。

これは、すでにある変数を指定したとしても、上書きするという処理でした。

```
if ("`replace'" == "replace"){
	qui cap drop `generate'
}
```

この部分で実行しています。

replaceの指定があれば、変数の削除を試みるという処理です。

また、他のローカルマクロは、都道府県の値を割り振る際に利用しています（北海道を例に）。

```
replace `generate' =  1 `in' `if' & (regexm(`varlist', "北海道") | regexm(`varlist', "[H/h]okkaido"))
```

ここで注意が必要なのはif節の運用です。

ifが指定されているときには問題ありませんが、**ifが指定されていないときには``ローカルマクロ `if'  ``は空白になり、上記はエラーになります。**

つまり、

```
pref2code pref in 1/40, gen(pref_code) replace
```

このような指定を行った場合、北海道のreplaceは次の様に解釈されます。

```
replace pref_code =  1 in 1/40  & (regexm(pref, "北海道") | regexm(`varlist', "[H/h]okkaido"))
```

if節が消えてしまったにも関わらず、regexm関数を連結しているので、エラーになってしまいます。

そこで、コマンドでif節を呼び出ししなかった場合の処理を追加しています。

```
if ("`if'" == ""){
	local if "if 1"
}
```

この処理では、if節が空白だったときに、``ローカルマクロ `if' ``に対して、``if 1``を指定します。

この処理を追加しておけば、下記の様になります。

```
replace pref_code =  1 in 1/40  if 1 & (regexm(pref, "北海道") | regexm(`varlist', "[H/h]okkaido"))
```

if節が復活し、`if 1 & (条件1 | 条件2)`という形になっています。

if節中の「1」は条件が常に成立することを意味しますので、下記2つは同値です。
* `if 1 & (条件1 | 条件2)`
* `if (条件1 | 条件2)`

もともと、pref2codeでのif節が空白の時の処理でしたので、この処理で想定通りの処理になります。

最終的に、確認のための出力をコメントアウトして、下記のテストを行います。

```
pref2code pref in 1/36 if Y19M01 > 5000, gen(pref_code) replace
list pref pref_code Y19M01
```

この実行によって、下記の10都道府県のみがコード化されているはずです。

北海道、埼玉、千葉、東京、神奈川、新潟、愛知、大阪、兵庫、広島

pref2code.adoファイルを修正したのに、上手くいかない場合は、``program drop pref2code``の実行を忘れていないか確認して下さい。

