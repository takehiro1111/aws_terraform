FROM --platform=linux/x86_64 locustio/locust@sha256:4de360964029e810fd16709277ba9d154d8d593add449817cfece4721682e810

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


