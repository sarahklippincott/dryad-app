require 'aws-sdk-s3'

module Stash
  module S3
    class Test
      def initialize
        # setting up basics
        bucket_name = APP_CONFIG['s3_bucket']
        s3_credentials = Aws::Credentials.new(APP_CONFIG['s3_key'], APP_CONFIG['s3_secret'])
        s3_client = Aws::S3::Client.new(region: 'us-west-2', credentials: s3_credentials)
        @s3_resource = Aws::S3::Resource.new(client: s3_client)
      end

      # TODO: fix this method to be modular
      def upload
        s3_directory = 'test01'
        file_path = './testing.txt'
        file_name = File.basename(file_path)

        # s3 action
        target_object = s3_resource.bucket(bucket_name).object("#{s3_directory}/#{file_name}")
        target_object.upload_file(file_path)
      end

    end
  end
end
