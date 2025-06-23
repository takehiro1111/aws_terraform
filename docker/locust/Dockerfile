FROM --platform=linux/x86_64 locustio/locust@sha256:c6df1a2cbfe89d161a3734522ad269ba855bf82c800897f42415de1470ae5378

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


