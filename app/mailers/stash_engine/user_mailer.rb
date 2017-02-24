module StashEngine

  # Mails users about submissions
  class UserMailer < ApplicationMailer
    # TODO: DRY these methods

    # add the formatted_date helper for view BAH -- doesn't seem to work
    # helper :formatted_date

    default from: "Dash Notifications <#{APP_CONFIG['feedback_email_from']}>",
      return_path: (APP_CONFIG['feedback_email_from']).to_s

    def error_report(resource, error)
      warn("Unable to report update error #{error}; nil resource") unless resource
      return unless resource

      user = resource.user
      @user_name = "#{user.first_name} #{user.last_name}"
      @user_email = user.email
      @title = resource.primary_title
      @identifier_uri = resource.identifier_uri
      @identifier_value = resource.identifier_value
      @backtrace = to_backtrace(error)

      to_address = to_address_list(APP_CONFIG['feedback_email_to'])
      mail(to: to_address, subject: "Submitting dataset \"#{@title}\" (doi:#{@identifier_value}) failed")
    end

    def submission_succeeded(resource)
      warn('Unable to report successful submission; nil resource') unless resource
      return unless resource

      user = resource.user
      @to_name = "#{user.first_name} #{user.last_name}"
      @title = resource.primary_title
      @identifier_uri = resource.identifier_uri
      @identifier_value = resource.identifier_value

      @embargo_date = nil
      @embargo_date = resource.embargo.end_date if resource.embargo

      tenant = user.tenant
      @host = tenant.full_domain

      to_address = to_address_list(user.email)
      mail(to: to_address, subject: "Dataset \"#{@title}\" (doi:#{@identifier_value}) submitted")
    end

    def submission_failed(resource, error)
      warn("Unable to report submission failure #{error}; nil resource") unless resource
      return unless resource

      user = resource.user
      @to_name = "#{user.first_name} #{user.last_name}"
      @title = resource.primary_title
      @identifier_uri = resource.identifier_uri
      @identifier_value = resource.identifier_value

      tenant = user.tenant
      @host = tenant.full_domain
      @contact_email = to_address_list(tenant.contact_email)

      @backtrace = to_backtrace(error)

      to_address = to_address_list(user.email)
      mail(to: to_address, subject: "Submitting dataset \"#{@title}\" (doi:#{@identifier_value}) failed")
    end

    private

    def to_address_list(addresses)
      addresses = [addresses] unless addresses.respond_to?(:join)
      addresses.join(',')
    end

    # TODO: look at Rails standard ways to report/format backtrace
    def to_backtrace(e)
      backtrace = (e.respond_to?(:backtrace) && e.backtrace) ? e.backtrace.join("\n") : ''
      "#{e.class}: #{e}\n#{backtrace}"
    end
  end
end
