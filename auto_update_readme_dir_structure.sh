#!/bin/bash

# treeコマンドでディレクトリ構造を取得
DIR_STRUCTURE=$(tree -d)

# READMEファイルの場所を指定
README_FILE="README.md"
START_MARKER="<!-- DIR_STRUCTURE_START -->"
END_MARKER="<!-- DIR_STRUCTURE_END -->"

# sedでREADME.mdを更新
sed -i 

echo "README.md has been updated with the latest directory structure."
