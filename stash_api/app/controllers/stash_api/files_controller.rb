# frozen_string_literal: true

require_dependency 'stash_api/application_controller'

module StashApi
  class FilesController < ApplicationController

    before_action -> { require_resource_id(resource_id: params[:version_id]) }, only: [:index]
    before_action -> { require_file_id(file_id: params[:id]) }, only: [:show]

    # get /files/<id>
    def show
      file = StashApi::File.new(file_id: params[:id])
      respond_to do |format|
        format.json { render json: file.metadata }
        format.html { render text: UNACCEPTABLE_MSG, status: 406 }
      end
    end

    # get /versions/<version-id>/files
    def index
      files = paged_files_for_version
      respond_to do |format|
        format.json { render json: files }
        format.html { render text: UNACCEPTABLE_MSG, status: 406 }
      end
    end

    private

    # rubocop:disable Metrics/AbcSize
    def paged_files_for_version
      resource = StashEngine::Resource.find(params[:version_id]) # version_id is really resource_id
      visible = resource.file_uploads.present_files
      all_count = visible.count
      file_uploads = visible.limit(page_size).offset(page_size * (page - 1))
      results = file_uploads.map { |i| StashApi::File.new(file_id: i.id).metadata }
      files_output(all_count, results)
    end
    # rubocop:enable Metrics/AbcSize

    def files_output(all_count, results)
      {
        '_links' => paging_hash(result_count: all_count),
        count: results.count,
        total: all_count,
        '_embedded' => { 'stash:files' => results }
      }
    end
  end
end