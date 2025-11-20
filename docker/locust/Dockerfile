FROM --platform=linux/x86_64 locustio/locust@sha256:d862a1577d5d487e7e378e7671ed189a51c67bf6a9310b72f958cd98928a2c7d

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


