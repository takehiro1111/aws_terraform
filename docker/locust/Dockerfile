FROM --platform=linux/x86_64 locustio/locust@sha256:28d2ed4b530819309d9b4839b39845795109c1201d74a53b3470ab3c8d8b95ef

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


