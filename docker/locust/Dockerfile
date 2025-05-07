FROM --platform=linux/x86_64 locustio/locust@sha256:3bd35c73b00ee1cdff70e0b391f621e013aa4fb9b687d8209c93f7f143132abc

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


