module StashEngine
  class FileUpload < ActiveRecord::Base
    belongs_to :resource, class_name: 'StashEngine::Resource'
    # mount_uploader :uploader, FileUploader # it seems like maybe I don't need this since I'm doing so much manually

    scope :deleted_from_version, -> { where(file_state: :deleted) }
    scope :newly_created, -> { where("file_state = 'created' OR file_state IS NULL") }
    scope :url_submission, -> { where("url IS NOT NULL") }
    scope :file_submission, -> { where("url IS NULL") }
    scope :errors, -> { where('url IS NOT NULL AND status_code <> 200') }
    enum file_state: %w(created copied deleted).map { |i| [i.to_sym, i] }.to_h

    # display the correct error message based on the url status code
    def error_message
      return '' if url.nil? || status_code == 200
      case status_code
        when 400
          "The request cannot be fulfilled due to bad syntax for the given URL #{url}."
        when 401
          "The given URL #{v.url} is unauthorized."
        when 403..404
          "The requested resource could not be found but may be available again in the future for the given URL #{url}."
        when 410
          "The requested page is no longer available for the given URL #{url}."
        when 414
          "The server will not accept the request, because the URL #{url} is too long."
        when 408, 499
          "The server timed out waiting for the request for the given URL #{url}."
        when 500..511
          "The server encountered an unexpected error which prevented it from fulfilling the request for the given URL #{url}."
        else
          "The given URL #{url} is invalid. Please check the URL and resubmit."
      end
    end
  end
end
