FROM --platform=linux/x86_64 locustio/locust@sha256:90fdf5b9632e67bb556d17784095652871be68318c5074731d911d4caaa42cc3

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


