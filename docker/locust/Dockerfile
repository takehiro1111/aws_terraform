FROM --platform=linux/x86_64 locustio/locust@sha256:535179f93b3f0340f1cc8591e7defe5ab78558d81b65a954555ebfe67fcc52c9

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


