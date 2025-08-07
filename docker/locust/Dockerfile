FROM --platform=linux/x86_64 locustio/locust@sha256:55dedcd76735acfe27093c827cfa546c45b68f45984c2daf829ec2d3030b7ec3

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


