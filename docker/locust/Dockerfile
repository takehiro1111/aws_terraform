FROM --platform=linux/x86_64 locustio/locust@sha256:7ebd75954600568b854fd3e016c21acc0acf04dc67e0ed53aea8dcf6a1b58413

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


