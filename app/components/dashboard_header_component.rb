# frozen_string_literal: true

# Show the header above a dashboard embed
class DashboardHeaderComponent < ApplicationComponent
  attr_reader :title, :link_text

  def initialize(title:, help_url:, link_text: 'Questions about this dashboard? Read the documentation')
    super()
    @title = title
    @help_url = help_url
    @link_text = link_text
  end
end
