FROM --platform=linux/x86_64 locustio/locust@sha256:f0990e216bb08f3a3e6b168c3bcdcbfdb644b3eae1936731af4c98b8cd1afa18

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


