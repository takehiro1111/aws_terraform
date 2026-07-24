FROM --platform=linux/x86_64 locustio/locust@sha256:fd39232c31971fe7509582717a95592f0fbf9a917b705f355bd7471e03bdd649

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


