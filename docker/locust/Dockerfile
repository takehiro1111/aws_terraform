FROM --platform=linux/x86_64 locustio/locust@sha256:d43616228012a7d79b883e2ecd42f87640469377f2b666c4ab27e5248dfdf35f

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


