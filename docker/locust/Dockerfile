FROM --platform=linux/x86_64 locustio/locust@sha256:382b4d66045060b4aa5609fa9081b6440880b5894dbf2934610befe41be27060

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


