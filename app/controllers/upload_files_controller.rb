class UploadFilesController < ApplicationController
  def index
    @resource = StashEngine::Resource.find(params[:id])
  end
end
