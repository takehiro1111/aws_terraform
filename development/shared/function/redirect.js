function handler(event) {
  const request = event.request;
  const targetHost = 'https://cdn.takehiro1111.com/static/index.html';


  const redirectResponse = {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        'location': {'value': targetHost},
        'cache-control': { 'value': 'max-age=6400'}
      }
  }

    console.log(`リダイレクト処理を行いました:${targetHost}`)

    return redirectResponse
}
