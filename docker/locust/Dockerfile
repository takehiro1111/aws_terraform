FROM --platform=linux/x86_64 locustio/locust@sha256:1f3ef394255beb83a82d1d7aa9a8ddc667fafd37b96ecb3a7be828948fc63a29

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


