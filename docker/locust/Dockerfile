FROM --platform=linux/x86_64 locustio/locust@sha256:f2aebc58ee9b276ac943f7ab4231d1d0378fc9df8d43d0453bc5505dff6b235f

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


