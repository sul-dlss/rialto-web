# frozen_string_literal: true

# Show the tabs above the dashboard embed
class DashboardTabComponent < ApplicationComponent
  def initialize(tabs:, dashboard: nil)
    super()
    @tabs = tabs
    @dashboard = dashboard
  end
  attr_reader :tabs, :dashboard

  def selected_tab
    params[:tab] || tabs.keys.first
  end
end
