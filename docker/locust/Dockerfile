FROM --platform=linux/x86_64 locustio/locust@sha256:99278f4b23e2353e7a93b84f9c270700c8193b90c1611f5c2a1817a111c22ee3

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


