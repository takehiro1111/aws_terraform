FROM --platform=linux/x86_64 locustio/locust@sha256:67af40288d36a2c4bcea69de5eee3c79e46a6f70bd396dda2fd47162623f81ec

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


