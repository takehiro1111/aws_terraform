FROM --platform=linux/x86_64 locustio/locust@sha256:8492fcaa6a07314551590f579219204e459d9fdc9dde060843bd2896e7a7259f

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


