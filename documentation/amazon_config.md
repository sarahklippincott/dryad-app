# Some things we must configure on Amazon

## Configure CORS on bucket for S3 upload

See https://github.com/TTLabs/EvaporateJS/wiki/Quick-Start-Guide though their
example is in XML which is no longer supported and now uses JSON.  See also
https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html .  Seems each domain
requires a new section and you can't list multiple under AllowedOrgins (?).

Examples:
```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT",
      "POST",
      "DELETE",
      "GET"
    ],
    "AllowedOrigins": [
      "http://localhost:3000"
    ],
    "ExposeHeaders": [
      "ETag"
    ],
    "MaxAgeSeconds": 3600
  }
]
```