FROM --platform=linux/x86_64 locustio/locust@sha256:a586fc4ddcd0ecd4f90f421f1d2ffce67529c140a0b51bbf7f55fcf4f08a87d7

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


