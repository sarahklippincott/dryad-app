# testing in here since testing is much better with real loading of the engines and application without wonky problems
# from the manual setup that doesn't really load rails right in the engines
require 'stash/merritt_download'
require 'byebug'
require 'http'
require 'fileutils'

RSpec.configure(&:infer_spec_type_from_file_location!)

module Stash
  module MerrittDownload
    RSpec.describe FileCollection do

      include Mocks::Tenant

      before(:each) do
        mock_tenant!
        @resource = create(:resource)
        @fc = FileCollection.new(resource: @resource)
      end

      describe '#initialize' do
        it 'has path set to store files' do
          expect(@fc.path.to_s).to end_with("zenodo_replication/#{@resource.id}")
        end

        it 'has blank info hash until downloads done' do
          expect(@fc.info_hash).to eq({})
        end

        it 'creates the directory to store the files' do
          expect(::File.directory?(@fc.path)).to eq(true)
        end
      end

      describe '#download_files' do
        before(:each) do
          @data_file = create(:data_file, resource_id: @resource.id)
        end

        it 'raises an exception for Merritt download errors' do
          stub_request(:get, %r{http://merritt-fake\.cdlib\.org/api/presign-file/.+})
            .to_return(status: 404, body: '', headers: {})
          expect { @fc.download_files }.to raise_error(Stash::MerrittDownload::DownloadError)
        end

        it 'raises an exception for S3 download errors' do
          # first return from Merritt
          stub_request(:get, @data_file.merritt_presign_info_url).to_return(status: 200,
                                                                            body: '{"url": "http://presigned.example.com/is/great/39768945"}',
                                                                            headers: { 'Content-Type': 'application/json' })

          stub_request(:get, 'http://presigned.example.com/is/great/39768945')
            .to_return(status: 404, body: '', headers: {})

          expect { @fc.download_files }.to raise_error(Stash::MerrittDownload::DownloadError)
        end

        it 'sets up info_hash on success' do
          # first return from Merritt
          stub_request(:get, @data_file.merritt_presign_info_url).to_return(status: 200,
                                                                            body: '{"url": "http://presigned.example.com/is/great/39768945"}',
                                                                            headers: { 'Content-Type': 'application/json' })

          stub_request(:get, 'http://presigned.example.com/is/great/39768945')
            .to_return(status: 200, body: '', headers: {})
          @fc.download_files
          expect(@fc.info_hash.keys).to include(@data_file.upload_file_name)
        end
      end
    end
  end
end
