# AWS Infrastructure as Code with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.x-blueviolet)](https://www.terraform.io/)

## Overview

このリポジトリは、AWS上にスケーラブルでセキュアなインフラをTerraformで構築するためのコードベースです。SRE/インフラエンジニアとして、インフラのコード化（IaC）により、効率的で再現性のある環境を提供することを目指しています。

## Key Features

- **Infrastructure as Code (IaC)**: 
  - Terraformを用いたコード化により、インフラの管理・構築が簡素化され、環境間の差異が減少します。
- **セキュリティとコンプライアンス**: 
  - IAM Identity Center、Organizations、MFA強制などを利用し、組織全体でのセキュリティの一貫性を保ちます。
- **モジュール化**: 
  - 再利用性を意識したモジュール化で、スケーラビリティと保守性を向上。
- **自動化**:
  - GitHub Actionsを活用して、CI/CDを通じたデプロイフローの自動化を実現しています。
- **コスト効率**: 
  - 不要なリソースのクリーンアップやコスト管理をサポートするコードも提供し、コスト最適化を図っています。

## Technology Stack

- **Terraform**: インフラ管理のメインツール。モジュールを利用した再利用性のあるコード設計。
- **AWS**: クラウドプロバイダ。EC2, S3, IAM, VPCなどの主要なAWSサービスを活用。
- **GitHub Actions**: CI/CDパイプラインの自動化。
- **その他**: CloudWatch, SNS, Lambdaなど、可観測性やアラートを強化するためのAWSサービスを適用。

## Repository Structure
```zsh
.
├── development  # 基本的なサービス作成
├── docs 
├── master # Organizarionsの管理アカウントで組織内で共通する設定を構築している。
│   └── account_management # IAM Identity Center & Organizationsを用いたアカウント管理の設定
├── modules
├── state  # 各AWSアカウントに配置しているステートファイル用のS3バケットを管理
└── stats # ログ収集用アカウント(未設定)
```

## Setup and Usage
1. **クローン**:
```zsh
   git clone https://github.com/takehiro1111/aws_terraform.git
   cd aws_terraform
```

2.Terraformの初期化:
```zsh
terraform init

```

3.計画の作成:
```zsh
cd environments/dev  # dev環境を例に
terraform plan

```


4.デプロイ:
```zsh
terraform apply
```

<div style="padding: 10px; border-left: 4px solid #f39c12; background-color: #fef9e7;">
<strong>注意</strong>: 適切なAWS認証情報とアクセス権限が必要です。
</div>

## Future Improvements
- 追加のセキュリティ強化: 既存のIAM設定に加え、IDP（Identity Provider）を使用したSSOの強化を検討。
- タグ管理の充実: リソースに一貫したタグを付与し、コスト分析やリソース追跡の精度向上を目指す。
- AWS Control Towerの導入: より高度なマルチアカウント管理とガバナンスを実現。
- モニタリングの拡張: AWS ConfigやCloudTrailを活用し、より詳細な変更監視やコンプライアンスチェックの強化。
- IDPとの連携: 外部のIdentity Provider (IDP) との統合を行い、IAM Identity Centerに加えて、IDPを挟んだ構成で認証フローを制御します。これにより、企業の既存の認証基盤（例: Azure AD, Oktaなど）と連携し、SSOや認証要件の統一を図ります。
- 各AWSアカウントの各サービスのログ基盤の整備
