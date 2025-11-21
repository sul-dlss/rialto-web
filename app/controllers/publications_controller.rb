# frozen_string_literal: true

# PublicationsController
class PublicationsController < PublicController
  # the type overview dashboard embedded view (stanford users only) -
  # turbo frame loaded only when tab is selected
  # This is the only view that is specific to PublicationsController,
  # the rest are defined in PublicController.
  def type_overview
    @tab_key = 'type-overview'
    render DashboardEmbedComponent.new(embed_url:,
                                       turbo_frame_id:, token:,
                                       authorized: stanford_access?)
  end

  def settings_tabs
    @settings_tabs ||= Settings.tabs.publications
  end

  def tableau_group
    'Publications'
  end

  def tab_routes
    {
      'stanford-overview' => { 'url' => publications_stanford_overview_path },
      'type-overview' => { 'url' => publications_type_overview_path },
      'school-details' => { 'url' => publications_school_details_path },
      'department-details' => { 'url' => publications_department_details_path }
    }
  end
end
