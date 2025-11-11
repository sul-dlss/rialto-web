# frozen_string_literal: true

# show the error alert
class ErrorComponent < ViewComponent::Base
  delegate :current_user, to: :helpers

  def initialize(type: 'dashboard')
    @type = type
    super()
  end

  attr_reader :type

  def alert_heading
    return "This #{type} is only available to Stanford-affiliated users." unless current_user

    "This #{type} is only available to select users."
  end
end
