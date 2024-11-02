import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# S3クライアントを作成
s3 = boto3.client('s3')

def list_s3_objects(bucket_name):
    #"""S3バケット内のオブジェクトをリストアップ"""
    paginator = s3.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket_name)
    
    for page in page_iterator:
        for obj in page.get('Contents', []):
            yield obj['Key']

def re_encrypt_object(bucket_name, key):
    #"""オブジェクトを再暗号化"""
    copy_source = {'Bucket': bucket_name, 'Key': key}
    s3.copy_object(
        Bucket=bucket_name,
        Key=key,
        CopySource=copy_source,
        MetadataDirective='COPY',
        ServerSideEncryption='AES256'
    )

def main():
    bucket_name = 'my-bucket'  # バケット名を指定

    try:
        print(f"Listing objects in bucket: {bucket_name}")
        for key in list_s3_objects(bucket_name):
            print(f"Re-encrypting object: {key}")
            re_encrypt_object(bucket_name, key)
        print("Re-encryption completed successfully.")

    except NoCredentialsError:
        print("AWS credentials not found.")
    except PartialCredentialsError:
        print("Incomplete AWS credentials.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
