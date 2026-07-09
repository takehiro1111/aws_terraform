FROM --platform=linux/x86_64 locustio/locust@sha256:2cc0f61b5a4234b76701f678b5957dc5209b115c0bf9fe480d690737c0243e63

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


