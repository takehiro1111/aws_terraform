#!/bin/zsh
PROJECTS=($(find . -type f -name ".envrc"))
MAIN_DIR=$(pwd)

# 色の定義
GREEN='\033[0;32m'
NC='\033[0m'

for project in "${PROJECTS[@]}" ; do
  # .envrcファイルのあるディレクトリに移動
  PROJECT_DIR=$(dirname "$project")
  
  # ディレクトリに移動してdirenv allowを実行し、元のディレクトリに戻る
  pushd "${MAIN_DIR}/${PROJECT_DIR}" > /dev/null
    if [ -d ".terraform" ]; then
      rm -rf ".terraform/"
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔${NC} Successfully removed .terraform directory in ${PROJECT_DIR}"
      fi
    else
      echo "No .terraform directory found in ${PROJECT_DIR}"
    fi
  popd > /dev/null
done
