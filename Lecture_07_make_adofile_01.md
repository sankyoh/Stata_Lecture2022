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

