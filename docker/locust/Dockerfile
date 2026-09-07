FROM --platform=linux/x86_64 locustio/locust@sha256:02109fe359906ebea8a1a1f4c1567771e815990739b9400c33d6c2692ac00af5

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


