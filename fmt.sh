#!/bin/bash

# リポジトリのメインディレクトリを取得
MAIN_DIR=$(git rev-parse --show-toplevel)

# メインディレクトリに移動
pushd "${MAIN_DIR}" > /dev/null

# Terraform fmt をリポジトリ全体に適用
terraform fmt --recursive

# メッセージを表示
echo "terraform fmt --recursive done"

# 元のディレクトリに戻る
popd > /dev/null
