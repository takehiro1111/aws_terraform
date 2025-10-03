FROM --platform=linux/x86_64 locustio/locust@sha256:95c573c961a107e4b9dbe491d98c497c216eb01e6cb74549c11e607a126d0872

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


