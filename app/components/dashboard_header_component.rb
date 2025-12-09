# frozen_string_literal: true

# Show the header above a dashboard embed
class DashboardHeaderComponent < ApplicationComponent
  attr_reader :title

  def initialize(title:, help_url:)
    super()
    @title = title
    @help_url = help_url
  end
end
