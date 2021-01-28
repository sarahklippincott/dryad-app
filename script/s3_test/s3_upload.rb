#!/usr/bin/env ruby
require 'aws-sdk-s3'

# setting up basics
bucket_name = 'dryad-test-s3'
s3_credentials = Aws::Credentials.new('', '')
s3_client = Aws::S3::Client.new(region: 'us-west-2', credentials: s3_credentials)
s3_resource = Aws::S3::Resource.new(client: s3_client)

# files
s3_directory = 'test01'
file_path = './testing.txt'
file_name = File.basename(file_path)

# s3 action
target_object = s3_resource.bucket(bucket_name).object("#{s3_directory}/#{file_name}")
target_object.upload_file(file_path)

