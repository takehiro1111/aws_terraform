FROM --platform=linux/x86_64 locustio/locust@sha256:c844f137efeb6185f55e1772fd126f488b146d4293ee350e1e7e424bcd69283c

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


