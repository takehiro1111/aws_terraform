FROM --platform=linux/x86_64 locustio/locust@sha256:fa127a3cd70428fd00d77f06e5deeb2550c93681f0ccfa1215645ca360ba57ac

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


