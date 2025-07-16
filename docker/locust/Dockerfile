FROM --platform=linux/x86_64 locustio/locust@sha256:18d078eb89d3f10124fb79db018c0f58a081a55af7790e2cfc484ab649c4323c

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


