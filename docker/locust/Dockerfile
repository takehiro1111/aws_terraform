FROM --platform=linux/x86_64 locustio/locust@sha256:0d7e43081c5f9437aed6513dc5827ec6984f024d00141a201a5b6be6e9a63e5d

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


