import boto3
client = boto3.client('sns')

def handler(event, context):
    
    params = {
    'TopicArn': 'arn:aws:sns:ap-northeast-1:421643133281:lambda-mail-sns-topic',
    'Subject': 'Subject Lambda(python) -> SNSでメール送ったよ',
    'Message': 'Message\n\nLambda -> SNSでメール送信できた事を確認。'
    }
    
    client.publish(**params)
