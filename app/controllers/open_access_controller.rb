# frozen_string_literal: true

# Controller for the open access dashboards
class OpenAccessController < PublicController
  # the school overview dashboard embedded view (stanford users only) -
  # turbo frame loaded only when tab is selected
  # This is the only view that is specific to OpenAccess,
  # the rest are defined in PublicController.
  def school_overview
    @tab_key = 'school-overview'
    render DashboardEmbedComponent.new(embed_url:,
                                       turbo_frame_id:, token:,
                                       authorized: stanford_access?)
  end

  def settings_tabs
    @settings_tabs ||= Settings.tabs.open_access
  end

  def tab_routes
    {
      'stanford-overview' => { 'url' => open_access_stanford_overview_path },
      'school-overview' => { 'url' => open_access_school_overview_path },
      'school-details' => { 'url' => open_access_school_details_path },
      'department-details' => { 'url' => open_access_department_details_path }
    }
  end

  def tableau_group
    'OpenAccess'
  end
end
