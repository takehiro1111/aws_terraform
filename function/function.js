function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // 新しいドメインURL
    var newDomain = 'https://cloudfront.tanaka-test.education.nextbeat.dev';

    // リクエストのURIを新しいドメインに追加
    var newUri = newDomain + uri;

    // 301 Moved Permanentlyステータスコードでリダイレクトレスポンスを生成
    return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
            'location': {
                'value': newUri
            }
        }
    };
}
