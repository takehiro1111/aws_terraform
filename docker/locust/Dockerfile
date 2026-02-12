FROM --platform=linux/x86_64 locustio/locust@sha256:d5eabf992ed996b823471e0be68ac57a0a123bad58dc6a2b7ffc121c04e57789

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


