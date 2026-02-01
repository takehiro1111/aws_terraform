FROM --platform=linux/x86_64 locustio/locust@sha256:ec4ad1854cb1dc92f529ce54976f1de019a5a9ae53945ba13d21e457516a121e

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


