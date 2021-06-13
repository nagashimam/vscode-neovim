#!/bin/bash
<<COMMENTOUT
# やりたいこと
当拡張機能に脆弱性が見つからないことを示したい
そのために、まずどんな外部モジュールをどのファイルで使っているかのリストを作成したい
COMMENTOUT

# $1 = 同一レポジトリのモジュールをリストから除外するかどうかのフラグ。1=除外する
# $2 = ;があるか探す行数
# $3 = ファイル名
findMatchingSemicolon() {
  local p="p"
  local line=$(sed -n "$2,$2p" $3)
  echo $line | grep \; -dskip &>/dev/null
  if [ "$?" -eq "0" ]; then
    # $1が1の場合、同一レポジトリの別モジュールはインポートのリストから除外
    echo $line | grep \.\/ -dskip &>/dev/null
    if [ $1 -eq "1" -a "$?" -eq "0" ]; then
      echo "0"
    else
      echo "$2"
    fi
  else
    findMatchingSemicolon $1 $(($2 + 1)) $3
  fi
}

# $1 = 同一レポジトリのモジュールをリストから除外するかどうかのフラグ。1=除外する
findImportedModule() {
  find . -path ./node_modules -prune -o -name "*.ts" | while read file; do
    importStartLines=($(sed -n "/^import/=" $file))
    for importStart in ${importStartLines[@]}; do
      # importにマッチするセミコロンがある行を探す
      importEnd=$(findMatchingSemicolon $1 $importStart $file)
      # 返り値0はリスト対象外
      if [ "$importEnd" != "0" ]; then
        p="p"
        importBlock=$(sed -n "$importStart,$importEnd$p" $file | tr -d "\r\n")
        echo "$file:$importBlock"
      fi
    done
  done
}
