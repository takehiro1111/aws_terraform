FROM --platform=linux/x86_64 locustio/locust@sha256:4d622e735d845d226931b4b60fd3a09518c0ae5f3449be0ed2418bbea92fb968

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


