require 'filesize'

module StashEngine
  module ApplicationHelper
    # displays log in/out based on session state, temporary for now
    # :nocov:
    def log_in_out
      if session[:user_id].blank?
        link_to 'log in', stash_url_helpers.tenants_path
      else
        link_to 'log out', stash_url_helpers.sessions_destroy_path
      end
    end
    # :nocov:

    # no decimal removes the after decimal bits
    def filesize(bytes, decimal_points = 2)
      return '' if bytes.nil?
      return "#{bytes} B" if bytes < 1000

      size_str = ::Filesize.new(bytes, Filesize::SI).pretty
      return size_str.gsub('.00', '') if decimal_points == 2

      matches = size_str.match(/^([0-9.]+) (\D+)/)
      number = matches[1].to_f
      units = matches[2]
      format("%0.#{decimal_points}f", number) + " #{units}"
    end

    def unique_form_id(for_object)
      return "edit_#{simple_obj_name(for_object)}_#{for_object.id}" if for_object.id

      "new_#{simple_obj_name(for_object)}_#{SecureRandom.uuid}"
    end

    def simple_obj_name(obj)
      obj.class.to_s.split('::').last.downcase
    end

    def file_type_path(file_obj)
      # polymorphic_path(file, resource_id: @resource.id, format: :js)
      # file_uploads_path(resource_id: @resource.id, format: :js)
    end

    # this translates our new models into the controllers for the old ones that used polymorphic path
    # ("file_upload" and "software_upload") since we're redoing all of this now, leaving the controllers in place
    # and translating from new models to old urls for old controllers.
    def polymorphic_translator(file_type, args={})
      action_type = 'index'
      if file_type.class == Array
        action_type, file_type = file_type
      end

      # file_uploads_path, new_file_upload_path, edit_file_upload_path, file_upload_path
      # software_uploads_path, new_software_upload_path, edit_software_upload_path, software_upload_path

      file_type = file_type.class unless file_type.is_a?(Class) # if instance get the class instead
      the_controller =  if file_type == StashEngine::DataFile
                          'file_uploads'
                        else
                          'software_uploads'
                        end
      url_for({controller: the_controller, action: action_type, only_path: true}.merge(args))
    end

  end
end
