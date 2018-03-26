module StashApi
  # takes a dataset hash, parses it out and saves it to the appropriate places in the database
  class DatasetParser
    def initialize(hash: nil, id: nil, user:)
      @hash = hash
      @id = id
      @user = user
      @resource = nil
    end

    def parse
      create_dataset if @resource.nil?
      @resource.update(title: @hash['title'])
      # probably want to clear and re-add authors for data updates
      @hash[:authors].each { |author| add_author(json_author: author) }
      StashDatacite::Description.create(description: @hash[:abstract], description_type: 'abstract', resource_id: @resource.id)
      @resource.identifier
    end

    private

    def create_dataset
      @resource = StashEngine::Resource.create(
        user_id: @user.id, current_editor_id: @user.id, identifier_id: nil, title: '', tenant_id: @user.tenant_id
      )
      # creating a new resource automatically creates an in-progress status and a version
      my_id = StashEngine.repository.mint_id(resource: @resource)
      id_type, id_text = my_id.split(':', 2)
      ident = StashEngine::Identifier.create(identifier: id_text, identifier_type: id_type.upcase)
      ident.resources << @resource
    end

    def add_author(json_author: author)
      a = StashEngine::Author.create(
        author_first_name: json_author[:firstName],
        author_last_name: json_author[:lastName],
        author_email: json_author[:email],
        resource_id: @resource.id
      )
      a.affiliation_by_name(json_author[:affiliation]) unless json_author[:affiliation].blank?
    end

  end
end