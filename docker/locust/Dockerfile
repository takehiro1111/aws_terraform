FROM --platform=linux/x86_64 locustio/locust@sha256:d8f9b42c5397e759db6945983d715b8afc9fa34797841c57eed908be36975090

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


