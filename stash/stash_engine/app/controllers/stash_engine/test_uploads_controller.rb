require_dependency 'stash_engine/application_controller'

module StashEngine
  class TestUploadsController < ApplicationController
    # GET /tenants
    def index
      # show the page
    end

    def presign_upload
      # this would presign the upload of a file
      byebug
    end
  end
end