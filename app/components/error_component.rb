# frozen_string_literal: true

# show the error alert
class ErrorComponent < ViewComponent::Base
  delegate :current_user, to: :helpers

  def alert_heading
    return 'This page is only available to Stanford-affiliated users.' unless current_user

    'This page is only available to approved users.'
  end

  def referrer
    request.headers['Turbo-Frame'] ? request.referer : request.original_url
  end

  def dua_form_url
    Settings.forms['data-use-agreement']
  end
end
