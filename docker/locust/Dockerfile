FROM --platform=linux/x86_64 locustio/locust@sha256:e6b8c3e7648b66d54b146815dd77f424a4f464056c9fbfeea46b4eccc743736a

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


