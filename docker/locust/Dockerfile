FROM --platform=linux/x86_64 locustio/locust@sha256:5f4024e5e219bd620f50e3fce096418d61a77bba3584be624702ed8c0847bf4e

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


