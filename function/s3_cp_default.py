import boto3

s3 = boto3.client('s3')
bucket_name = 'logging-sekigaku-20231120'

# バケット内のオブジェクトをリスト
response = s3.list_objects_v2(Bucket=bucket_name)

for obj in response.get('Contents', []):
    key = obj['Key']
    copy_source = {'Bucket': bucket_name, 'Key': key}
    
    # SSE-S3を使って再暗号化
    s3.copy_object(
        Bucket=bucket_name,
        Key=key,
        CopySource=copy_source,
        MetadataDirective='COPY',
        ServerSideEncryption='AES256'
    )

print("再暗号化完了")
