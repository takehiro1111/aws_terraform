FROM --platform=linux/x86_64 locustio/locust@sha256:ea785ebc49c887007e0e6809cc9a839edc0d2199a4ddf1d249f23f11fda52787

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


