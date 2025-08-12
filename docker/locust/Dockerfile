FROM --platform=linux/x86_64 locustio/locust@sha256:7917286b7616ee09f68f6ba0b8445d19daca327028c83e1c584bb3d8d10b7835

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


