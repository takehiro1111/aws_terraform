FROM --platform=linux/x86_64 locustio/locust@sha256:2d678784c74fd60a43f114fc1cb1068a383e1b0d34001f70e9f7105081d3fbbf

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


