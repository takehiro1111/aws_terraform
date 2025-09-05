FROM --platform=linux/x86_64 locustio/locust@sha256:5ccccd0e4cb3973d3e411ae46dd7c25026d96af08f454e8ba97def934a531d9a

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


