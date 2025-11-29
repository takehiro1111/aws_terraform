FROM --platform=linux/x86_64 locustio/locust@sha256:9cce1058a3d2fa02d8a2a909ad21a4fed9ae3d7a0d3556ab145bb1338dc4ecb5

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


