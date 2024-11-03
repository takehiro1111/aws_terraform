#!/bin/zsh
PROJECTS=($(find . -type f -name ".envrc"))
MAIN_DIR=$(pwd)
RETURN_DIR=..

for project in "${PROJECTS[@]}" ; do
    # .envrcファイルのあるディレクトリに移動
    PROJECT_DIR=$(dirname "$project")
    
    # ディレクトリに移動してdirenv allowを実行し、元のディレクトリに戻る
    pushd "${MAIN_DIR}/${PROJECT_DIR}" > /dev/null
    direnv allow
    popd > /dev/null
done
