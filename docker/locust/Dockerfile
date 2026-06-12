FROM --platform=linux/x86_64 locustio/locust@sha256:8e3e782a1484247d08341d8310861a9b8f59974b345a631144e81b051eb6c182

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


