# frozen_string_literal: true

# Concern for handling authentication.
# Note that this concern is based on the generated code.
module Authentication
  extend ActiveSupport::Concern

  # Apache is configured so that:
  # - /webauth/login requires a shibboleth authenticated user. Thus, redirecting a user to it triggers login.
  # - /Shibboleth.sso/Logout logs the user out of shibboleth.
  # - /queues is limited to members of the sdr:developer group.
  # - Other pages do not require authentication.
  # - It provides the following request headers:
  #  - X-Remote-User
  #  - X-Groups
  #  - X-Person-Name (first name)
  #  - X-Person-Formal-Name (full name)

  MAX_URL_SIZE = ActionDispatch::Cookies::MAX_COOKIE_SIZE / 2
  SHIBBOLETH_LOGOUT_PATH = '/Shibboleth.sso/Logout'

  USER_GROUPS_HEADER = 'X-Groups'
  FIRST_NAME_HEADER =  'X-Person-Name'
  FULL_NAME_HEADER = 'X-Person-Formal-Name'
  REMOTE_USER_HEADER = 'X-Remote-User'

  included do
    # It will authenticate the user if there is a user.
    # This will be called for all controller actions.
    before_action :authentication, :set_current_groups
    helper_method :authenticated?, :current_user
  end

  def current_user
    Current.user
  end

  private

  def remote_user
    return ENV.fetch('REMOTE_USER', nil) if Rails.env.development? && cookies[:logged_in]

    request.headers[REMOTE_USER_HEADER]
  end

  def authenticated?
    remote_user.present?
  end

  def authentication
    # This adds the cookie in development/test so that action cable can authenticate.
    start_new_session if start_new_session?
    resume_session
  end

  def start_new_session?
    return true if Rails.env.development? && remote_user && cookies[:logged_in]

    Rails.env.test? && user_attrs[:email_address].present?
  end

  def resume_session
    Current.user ||= User.find_by(email_address: remote_user)
  end

  def set_current_groups
    Current.groups ||= groups_from_session
  end

  def start_new_session
    # Create or update a user based on the headers provided by Apache.
    User.upsert(user_attrs, unique_by: :email_address) # rubocop:disable Rails/SkipsModelValidations
  end

  def user_attrs # rubocop:disable Metrics/AbcSize
    return development_user_attrs if Rails.env.development?

    {
      email_address: request.headers[REMOTE_USER_HEADER] || request.cookies['test_shibboleth_remote_user'],
      name: request.headers[FULL_NAME_HEADER] || request.cookies['test_shibboleth_full_name'],
      first_name: request.headers[FIRST_NAME_HEADER] || request.cookies['test_shibboleth_first_name']
    }
  end

  def development_user_attrs
    {
      email_address: ENV.fetch('REMOTE_USER', 'test'),
      name: 'User',
      first_name: 'Test'
    }
  end

  # This looks first in the session for groups, and then to the headers.
  # This allows the application session to outlive the shibboleth session
  def groups_from_session
    return ENV.fetch('ROLES', '').split(';').compact.uniq if Rails.env.development?
    return [] unless authenticated?

    session['groups'] ||= begin
      raw_header = request.headers[USER_GROUPS_HEADER] || ''
      raw_header.split(';')
    end
  end

  def terminate_session
    cookies.delete(:logged_in)
  end
end
