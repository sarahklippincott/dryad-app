module StashDatacite
  class ResourcesSubjects < ActiveRecord::Base
    self.table_name = 'dcs_subjects_stash_engine_resources'
    belongs_to :resource, class_name: StashEngine::Resource.to_s
    has_many :subjects
  end
end