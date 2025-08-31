FROM --platform=linux/x86_64 locustio/locust@sha256:33a0b1963f9fba57ff99dc7d845a8f3178870f9404624cc25d497a88bb1dfe21

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


