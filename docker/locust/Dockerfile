FROM --platform=linux/x86_64 locustio/locust@sha256:c738f7829c48c956cc10b243b788691869bb1e583c578dd06be529af5b9b20b1

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


