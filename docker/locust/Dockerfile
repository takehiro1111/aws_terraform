FROM --platform=linux/x86_64 locustio/locust@sha256:27fcce7937515842cbd570d050d9666da626060f565d1a06cf1b8e3e47dffa78

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


