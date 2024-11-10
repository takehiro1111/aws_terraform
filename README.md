# AWS Infrastructure as Code with Terraform
![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623ce4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Ready-FF9900?logo=amazonaws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Enabled-2088FF?logo=github-actions&logoColor=white)


## Overview

このリポジトリは、AWS上にスケーラブルでセキュアなインフラをTerraformで構築するためのコードベースです。SRE/インフラエンジニアとして、インフラのコード化（IaC）により、効率的で再現性のある環境を提供することを目指しています。

## Key Features

- **Infrastructure as Code (IaC)**
  - Terraformを用いたコード化により、インフラの管理・構築が簡素化され、環境間の差異が減少します。
- **セキュリティとコンプライアンス**
  - IAM Identity Center、Organizations、MFA強制などを利用し、組織全体でのセキュリティの一貫性を保ちます。
- **自作Module,公式Moduleを用いることによるコードの再利用性向上** 
  - 再利用性を意識したモジュール化で、スケーラビリティと保守性を向上。
- **自動化**
  - GitHub Actionsを活用して、CI/CDを通じたデプロイフローの自動化を実現しています。
- **コスト効率**:
  - 不要なリソースのクリーンアップやコスト管理をサポートするコードも提供し、コスト最適化を図っています。

## Future Improvements

- **追加のセキュリティ強化** 
  - 既存のIAM設定に加え、IDP（Identity Provider）を使用したSSOの強化
  - WAFでのアクセス制御
  - SecurityHub,GuardDuty等のマネージドでの脅威検知の実施
  - IDPとの連携: 外部のIdentity Provider (IDP) との統合を行い、IAM Identity Centerに加えて、IDPを挟んだ構成で認証フローを制御します。これにより、企業の既存の認証基盤（例: Azure AD, Oktaなど）と連携し、SSOや認証要件の統一を図ります
- **コスト最適化**
  - リソースに一貫したタグを付与し、コスト分析やリソース追跡の精度向上を目指す。
  - EventBridgeを使用して時間帯でのリソース停止
  - GithubActionsでのリソース削除をCRONで実施
- **運用の最適化**
  - AWS Control Towerの導入: より高度なマルチアカウント管理とガバナンスを実現。
  - モニタリングの拡張: AWS ConfigやCloudTrailを活用し、より詳細な変更監視やコンプライアンスチェックの強化。
  - 各AWSアカウントの各サービスのログ基盤の整備
  - Lambdaによるコスト使用量のSlack通知の改修

## Repository Structure
```
[ディレクトリ構成ファイル](tree.txt)
```

## Setup and Usage
### 1. **Clone & Move Directory**
#### 1-1.リポジトリをローカル環境へクローンする。
```zsh
git clone https://github.com/takehiro1111/aws_terraform.git
cd aws_terraform/{hoge_hoge}

```

#### 1-2.プロジェクトの初期化
```zsh
terraform init

```

#### 1-3.hclで記述したコードと実際の設定との差分を確認
```zsh
terraform plan
```


#### 1-4.差分が問題なければ、Deployの実施
```zsh
terraform apply

```

<div style="padding: 10px; border-left: 4px solid #f39c12; background-color: #fef9e7;">
<strong>注意</strong>: 適切なAWS認証情報とアクセス権限が必要です。
</div>

### 2. **Terraformの認証情報を`direnv`で自動取得する手順**

#### 2-1.手動での設定
  - cdコマンドでTerraformファイルのあるディレクトリに移動し、direnv allowを実行して環境変数を読み込みます。
```
cd {tfファイルのカレントdir}
direnv allow
```

#### 2-2.自動での設定
  - allow_envrc.shスクリプトを用意している場合は、以下のコマンドで自動的に環境設定を適用できます。
```
source allow_envrc.sh
```

#### 2-3.IAM Identity Centerへのログイン
  - IAM Identity Center）を使ってログインし、Terraformで認証できるようにします。
```
aws sso login --profile $AWS_PROFILE
```
  - Reference
   https://zenn.dev/takehiro1111/articles/direnv_20240203
