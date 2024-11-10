#!/bin/bash

# treeコマンドでディレクトリ構造を取得
DIR_STRUCTURE=$(tree -d -L 2)

# READMEファイルの場所を指定
README_FILE="README.md"
START_MARKER="<!-- DIR_STRUCTURE_START -->"
END_MARKER="<!-- DIR_STRUCTURE_END -->"

# `sed`コマンドでマーカー間の内容を直接置き換え
sed -i '' "/$START_MARKER/,/$END_MARKER/{ /$START_MARKER/{p; d;}; /$END_MARKER/p; d; }" "$README_FILE"

# マーカー間にディレクトリ構造を挿入
printf "%s\n\`\`\`bash\n%s\n\`\`\`\n%s\n" "$START_MARKER" "$DIR_STRUCTURE" "$END_MARKER" | sed -i '' "/$START_MARKER/r /dev/stdin" "$README_FILE"

echo "README.md has been updated with the latest directory structure."
