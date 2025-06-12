FROM --platform=linux/x86_64 locustio/locust@sha256:fe2b11f6d46bb12239c738c44c46d93a6d78d1ba4f679b9e3a673cc843d933ac

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


