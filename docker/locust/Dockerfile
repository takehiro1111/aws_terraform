FROM --platform=linux/x86_64 locustio/locust@sha256:d0f0258bd0055af2d4ab93012b83df1b52c482ad3aaa9887698c24d0145d27dc

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


