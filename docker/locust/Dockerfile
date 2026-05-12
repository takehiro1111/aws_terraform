FROM --platform=linux/x86_64 locustio/locust@sha256:7acfc1db2477028fcb5632ec00c4cce7efbbf1a420e0edc2238f7a69c660cf7b

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


