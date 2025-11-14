# frozen_string_literal: true

# Show the tabs above the dashboard embed
class DashboardTabComponent < ApplicationComponent
  def initialize(tabs:)
    super()
    @tabs = tabs
  end
  attr_reader :tabs

  def selected_tab
    params[:tab] || tabs.keys.first
  end
end
