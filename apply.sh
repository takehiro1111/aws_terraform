#!/bin/zsh

DIR=""
echo "$DIR"
if [ -d "$DIR" ]; then
  pushd "$DIR" > /dev/null
  terraform init
  terraform plan
  terraform apply
  popd > /dev/null
fi
