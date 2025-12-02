# frozen_string_literal: true

# show the error alert
class ErrorComponent < ViewComponent::Base
  delegate :current_user, to: :helpers

  def alert_heading
    return 'This page is only available to Stanford-affiliated users.' unless current_user

    'This page is only available to select users.'
  end
end
