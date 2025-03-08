FROM --platform=linux/x86_64 locustio/locust@sha256:e67a79c59e45c3aa81e1f64b0b20f111f67dcad37b4bbb0b10f323ee238cc6e2

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


