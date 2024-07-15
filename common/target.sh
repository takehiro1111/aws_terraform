#!/bin/bash

# Terraformの状態から対象のリソースを抽出
targets=$(terraform state list | grep -E 'aws_wafv2_web_acl\..*')

# ターゲットリソースを指定するためのオプションを生成
target_opts=""
for target in $targets; do
  target_opts="$target_opts -target=$target"
done

echo $target_opts
