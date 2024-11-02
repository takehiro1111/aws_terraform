import boto3

def create_s3_bucket(acl,bucket,region,objectlock = False,objectowner = 'BucketOwnerPreferred',*args,**kwargs):
  client = boto3.client('s3')
  response = client.create_bucket(
      ACL= acl,
      Bucket= bucket,
      CreateBucketConfiguration={
          'LocationConstraint': region
      },
      ObjectLockEnabledForBucket= objectlock,
      ObjectOwnership= objectowner
  )
  return response

sdk = create_s3_bucket('private','boto3-client-20240718', 'ap-northeast-1')
print(sdk)

