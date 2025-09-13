FROM --platform=linux/x86_64 locustio/locust@sha256:6e6519f39294caaa577e5be7a0437b4b18a0f057fa58dc061676c824365307ce

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


