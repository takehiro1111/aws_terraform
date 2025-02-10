FROM --platform=linux/x86_64 locustio/locust@sha256:388d9c975ec6fc0e4293960bbd578aedb68cf7a8ce45ab66c0cbffb8b5524b7c

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


