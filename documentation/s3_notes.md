## S3 ACLs
- By default owner has access
- grant *id* (for user), *uri* (for group), *email (for user)
- S3 predefined groups
  - Authenticated users group http://acs.amazonaws.com/groups/global/AuthenticatedUsers
  - Anyone: http://acs.amazonaws.com/groups/global/AllUsers
- ACL Permissions READ, WRITE, READ_ACP, WRITE_ACP, FULL_CONTROL, they may differ slightly from bucket or object scope
- Access policy permissions see https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
- Access policy conditions -- you can use permission keys to constrain
the value of the acl.  Mandate use of specific ACL
  - s3:x-amz-grant-read ‐ Require read access. 
  - s3:x-amz-grant-write ‐ Require write access.
  - s3:x-amz-grant-read-acp ‐ Require read access to the bucket ACL.
  - s3:x-amz-grant-write-acp ‐ Require write access to the bucket ACL.
  - s3:x-amz-grant-full-control ‐ Require full control.
  - s3:x-amz-acl ‐ Require a Canned ACL.
- Canned ACLs support predefined grants like private, public-read, public-read-write, aws-exec-read,
authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write
- S3 doesn't really use folders but it's just a string that can look like a directory.
No objects with trailing slashes.
- bucket names are unique across all of Amazon

## My Config
Bucket name: dryad-test-s3 (us-west-2)
