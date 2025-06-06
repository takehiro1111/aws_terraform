FROM --platform=linux/x86_64 locustio/locust@sha256:8064671725385b83d8b04bfe641e76f765b831f0516018ad390bb1f17c188e73

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


