FROM --platform=linux/x86_64 locustio/locust@sha256:e45645e931b59143e2670854ef729ee5bb7694a07ebc9ae974d00f643bede3b3

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


