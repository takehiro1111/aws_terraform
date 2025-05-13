FROM --platform=linux/x86_64 locustio/locust@sha256:66dbde5e817fb620acb5fcebcdec71052e6d881aa1e4c6764a790eb96b3a2b0d

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


