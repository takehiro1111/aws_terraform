FROM --platform=linux/x86_64 locustio/locust@sha256:ce78eb12e88a5c8a514c849ab40cc55c1779c175e0233b94bff1e36322bc0804

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


