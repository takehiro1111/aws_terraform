FROM --platform=linux/x86_64 locustio/locust@sha256:878af5232072a7379157ddfbb87a63a4be54c854f7bee4626aab4831fcadb88c

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


