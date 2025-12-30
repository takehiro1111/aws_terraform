FROM --platform=linux/x86_64 locustio/locust@sha256:aca41c1b80bd09d04ddb75cbd533870922b548c287c3543a77cb7215840108bf

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


