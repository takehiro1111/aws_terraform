FROM --platform=linux/x86_64 locustio/locust@sha256:38350f8c9824b8d31d3cf7ccb628eee4aa05c5975db3568f9ef097445e89a460

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


