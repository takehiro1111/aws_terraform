FROM --platform=linux/x86_64 locustio/locust@sha256:f8dbe965cba645062c94a6c484b2b8d272e8854c34bb7328b36ae0c176ef6f1e

# 作業ディレクトリを設定
WORKDIR /src

# 依存関係をインストール
COPY ./src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# テストスクリプトをコピー
COPY ./src/ .

# 必要なポートを公開
EXPOSE 8089
EXPOSE 5557
EXPOSE 5558


