FROM --platform=linux/x86_64 locustio/locust@sha256:cb29b8e1e3c1cfbddd1070e6e6e3abd7c28fe1c764aa525c03a77e928ea218cd

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


