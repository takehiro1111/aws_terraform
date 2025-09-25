FROM --platform=linux/x86_64 locustio/locust@sha256:d3a8dd3e19270b7b976532a836c72d1483b9a08cbd8d4c37cf83e533040e8065

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


