# terraform-aws-infra-playground

Terraform を使って AWS 上にセキュアなネットワーク構成を IaC で構築するポートフォリオプロジェクトです。
踏み台サーバー（Bastion）経由でプライベートサブネット内の API サーバーにアクセスする、実務を想定したインフラ設計を実装しています。

---

## アーキテクチャ概要

```
Internet
    │
    ▼
Internet Gateway
    │
    ├── Public Subnet (10.0.1.0/24)
    │       └── Bastion EC2 (t3.micro)  ← 自分の IP からのみ SSH 許可
    │
    └── Private Subnet (10.0.2.0/24)
            └── API EC2 (t3.micro)      ← Bastion からのみ SSH 許可
```

- VPC・サブネット・ルートテーブル・セキュリティグループをすべて Terraform で管理
- プライベートサブネットの API サーバーはインターネットに直接公開しない設計
- セキュリティグループはソース IP を `my_ip` 変数で制限し、不要なポートを一切開放しない最小権限構成

---

## 使用技術

| 技術 | バージョン | 用途 |
|------|-----------|------|
| Terraform | >= 1.2 | IaC |
| AWS Provider | ~> 6.50 | AWS リソース管理 |
| Amazon Linux 2023 | 最新 AMI を自動取得 | EC2 OS |
| S3 Backend | - | tfstate のリモート管理・ロック |

---

## ポイント・工夫した点

**セキュリティ設計**

- Bastion への SSH は `my_ip` 変数で自分の IP のみに制限（`/32` CIDR）
- API サーバーへの SSH は Bastion のセキュリティグループを参照元に指定。IP 指定ではなく SG 参照にすることで Bastion の IP 変更に自動追従
- プライベートサブネットはパブリック IP を付与せず、インターネットへの経路も持たない

**Terraform のベストプラクティス**

- `data "aws_ami"` で最新の Amazon Linux 2023 AMI を動的に取得。AMI ID のハードコードを排除
- S3 バックエンドで tfstate をリモート管理。`use_lockfile = true` により同時実行による状態ファイルの競合を防止
- 変数は `variables.tf` に分離し、機密情報（`my_ip`）はデフォルト値を持たせず実行時に渡す構成

---

## 前提条件

- Terraform >= 1.2
- AWS CLI の設定済み（`~/.aws/credentials` または 環境変数）
- SSH キーペアの作成済み（デフォルト: `~/.ssh/terraform-aws-infra-playground.pub`）
- tfstate 管理用 S3 バケット（`remote-backend-riorio-bucket`）の作成済み

---

## 使い方

```bash
# 初期化（S3 バックエンドの設定を含む）
terraform init

# 実行計画の確認（自分の IP を渡す）
terraform plan -var="my_ip=xxx.xxx.xxx.xxx"

# インフラの構築
terraform apply -var="my_ip=xxx.xxx.xxx.xxx"

# リソースの削除
terraform destroy -var="my_ip=xxx.xxx.xxx.xxx"
```

---

## ディレクトリ構成

```
.
├── main.tf        # VPC・EC2・SG などのリソース定義
├── variables.tf   # 変数定義
└── terraform.tf   # プロバイダー・バックエンド・バージョン設定
```

---

## 今後の拡張予定

- NAT Gateway を追加し、プライベートサブネットからの外向き通信を可能にする
- ALB + Auto Scaling Group による冗長構成への移行
- GitHub Actions による CI/CD パイプラインの構築（`terraform fmt` / `validate` / `plan` の自動化）
- マルチ AZ 構成への対応
