FROM --platform=linux/x86_64 locustio/locust@sha256:13351310332ac2d459e01a2b340432c5bfd509fa09838d2aa9d1f15dc49ff135

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


