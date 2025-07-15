FROM --platform=linux/x86_64 locustio/locust@sha256:226e4b4ccb40c847be1687b6655a7bb1cb329838bc9a1fbdf581c04cc0c7e5de

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


