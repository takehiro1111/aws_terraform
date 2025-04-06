FROM --platform=linux/x86_64 locustio/locust@sha256:5ea351d0ff6f657fb27942580f2485687b896a204f662ef8482a4d48faa9bce0

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


