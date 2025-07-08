FROM --platform=linux/x86_64 locustio/locust@sha256:07f299c5056ce0124d664d2b93d03fd4b23143c402c2bc63f8df3d30fd7f6137

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


