# frozen_string_literal: true

# Controller for the orcid dashboards
class OrcidAdoptionController < PublicController
  # the individual researchers dashboard embedded view (workgroup users only) -
  # turbo frame loaded only when tab is selected
  # This is the only view that is specific to OrcidAdoption,
  # the rest are defined in PublicController.
  def researcher_details
    @tab_key = 'researcher-details'
    render DashboardEmbedComponent.new(embed_url:,
                                       turbo_frame_id:, token:,
                                       authorized: business_access?)
  end

  def settings_tabs
    @settings_tabs ||= Settings.tabs.orcid_adoption
  end

  def tab_routes
    {
      'stanford-overview' => { 'url' => orcid_adoption_stanford_overview_path },
      'researcher-details' => { 'url' => orcid_adoption_researcher_details_path },
      'department-details' => { 'url' => orcid_adoption_department_details_path }
    }
  end

  def tableau_group
    'ORCIDAdoption'
  end
end
