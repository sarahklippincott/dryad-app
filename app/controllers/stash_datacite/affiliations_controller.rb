require_dependency 'stash_datacite/application_controller'

module StashDatacite
  class AffiliationsController < ApplicationController

    include Stash::Organization

    # GET /affiliations/autocomplete
    def autocomplete
      partial_term = params['query']
      if partial_term.blank?
        render json: nil
      else
        # clean the partial_term of unwanted characters so it doesn't cause errors when calling the ROR API
        partial_term.gsub!(%r{[/\-\\()~!@%&"\[\]\^:]}, ' ')
        @affiliations = Stash::Organization::Ror.find_by_ror_name(partial_term)
        render json: @affiliations
      end
    end

  end
end
