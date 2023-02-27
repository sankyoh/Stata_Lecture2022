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


