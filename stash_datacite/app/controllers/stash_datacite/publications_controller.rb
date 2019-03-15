require_dependency 'stash_datacite/application_controller'
require 'httparty'
require 'byebug'

module StashDatacite
  class PublicationsController < ApplicationController
    # include HTTParty

    # rubocop:disable Metrics/AbcSize
    def update
      @se_id = StashEngine::Identifier.find(params[:internal_datum][:identifier_id])
      @pub_issn = StashEngine::InternalDatum.find_or_create_by(stash_identifier: @se_id, data_type: 'publicationISSN')
      @msid = StashEngine::InternalDatum.find_or_create_by(stash_identifier: @se_id, data_type: 'manuscriptNumber')
      issn =  params[:internal_datum][:publication_issn]
      msid = params[:internal_datum][:msid]
      @pub_issn.update(value: issn) unless issn.blank?
      @msid.update(value: msid) unless msid.blank?
      respond_to do |format|
        format.js {
          if params[:internal_datum][:do_import] == 'true'
            # take action to do the actual import and reload the page with javascript
            update_metadata
            render 'update' # just the standard update in the associated view directory
          else
            render template: 'stash_datacite/shared/update.js.erb'
          end
        }
      end
    end

    # rubocop:disable Metrics/MethodLength
    def update_metadata
      pub_issn_only = @pub_issn.value
      msid_only = @msid.value
      body = { dryadDOI: 'doi:' + @se_id.identifier,
               dashUserID: current_user.id,
               manuscriptNumber: msid_only }.to_json
      url = "#{APP_CONFIG.old_dryad_url}/api/v1/journals/#{pub_issn_only}/packages/"
      @results = HTTParty.put(url,
                              query: { access_token: APP_CONFIG.old_dryad_access_token },
                              body: body,
                              headers: { 'Content-Type' => 'application/json' })
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

  end
end
