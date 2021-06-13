#!/bin/bash
<<COMMENTOUT
# やりたいこと
当拡張機能に脆弱性が見つからないことを示したい
そのために、まずどんな外部モジュールをどのファイルで使っているかのリストを作成したい
COMMENTOUT

# $1 = ;があるか探す行数
# $2 = ファイル名
findMatchingSemicolon() {
  local p="p"
  local line=$(sed -n "$1,$1p" $2)
  echo $line | grep \; -dskip &>/dev/null
  if [ "$?" -eq "0" ]; then
    # ./からimport = 同一レポジトリの別モジュールをインポートしている場合、リストから外す
    echo $line | grep \.\/ -dskip &>/dev/null
    if [ "$?" -eq "0" ]; then
      echo "0"
    else
      echo "$1"
    fi
  else
    findMatchingSemicolon $(($1 + 1)) $2
  fi
}

# 出力ファイルの初期化
: >import-list.csv
find . -path ./node_modules -prune -o -name "*.ts" | while read file; do
  importStartLines=($(sed -n "/^import/=" $file))
  for importStart in ${importStartLines[@]}; do
    # importにマッチするセミコロンがある行を探す
    importEnd=$(findMatchingSemicolon $importStart $file)
    # 返り値0は同一レポジトリ別モジュールからのインポートなので、リストから除外
    if [ "$importEnd" != "0" ]; then
      p="p"
      importBlock=$(sed -n "$importStart,$importEnd$p" $file | tr -d "\r\n")
      echo "$file:$importBlock" >>import-list.csv
    fi
  done
done
