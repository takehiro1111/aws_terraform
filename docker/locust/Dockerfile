FROM --platform=linux/x86_64 locustio/locust@sha256:c6d7a36aa99a406575ec02da444f404718175a209618f0cd4abe35e1eaa2110e

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


