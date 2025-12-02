# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show orcid dashboard pages' do
  let(:name) { 'Awesome Dude' }
  let(:tableau_url) { "#{Settings.tableau.base_url}#{Settings.tableau.dashboard_base_path}ORCIDAdoption/" }

  context 'when user is logged in but is not in the business case workgroup' do
    let(:user) { create(:user, name:) }

    before do
      sign_in(user)
    end

    it 'shows the orcid dashboard stanford overview viz in tab' do
      visit orcid_adoption_dashboard_path

      expect(page).to have_content('ORCID Adoption Dashboard')
      within('#stanford-overview-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}StanfordOverview\"]")
      end
    end

    it 'shows the orcid dashboard schools and departments viz in tab' do
      visit orcid_adoption_dashboard_path(tab: 'department-details')
      within('#department-details-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}DepartmentDetails\"]")
      end
    end

    it 'does not show the orcid dashboard individual researchers viz in tab' do
      visit orcid_adoption_dashboard_path(tab: 'researcher-details')
      expect(page).to have_content('This page is only available to select users.')
      within('#researcher-details-frame') do
        expect(page).to have_no_css('#tableau-viz')
      end
    end
  end

  context 'when user is logged in and is in the business case workgroup' do
    let(:user) { create(:user, name:) }
    let(:workgroup_name) { Settings.authorization_workgroup_names.rialto }

    before do
      sign_in(user, groups: [workgroup_name])
    end

    it 'shows the orcid dashboard individual researchers viz in tab' do
      visit orcid_adoption_dashboard_path(tab: 'researcher-details')
      within('#researcher-details-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}ResearcherDetails\"]")
      end
    end
  end

  context 'when user is not logged in' do
    before do
      visit logout_path
    end

    it 'shows the orcid dashboard stanford overview viz in tab' do
      visit orcid_adoption_dashboard_path

      expect(page).to have_content('ORCID Adoption Dashboard')
      within('#stanford-overview-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}StanfordOverview\"]")
      end
    end

    it 'does not show the orcid dashboard schools and departments viz in tab' do
      visit orcid_adoption_dashboard_path(tab: 'department-details')
      within('#department-details-frame') do
        expect(page).to have_no_css('#tableau-viz')
      end
      expect(page).to have_content('This page is only available to Stanford-affiliated users.')
    end

    it 'does not show the orcid dashboard individual researchers viz in tab' do
      visit orcid_adoption_dashboard_path(tab: 'researcher-details')
      within('#researcher-details-frame') do
        expect(page).to have_no_css('#tableau-viz')
      end
      expect(page).to have_content('This page is only available to Stanford-affiliated users.')
    end
  end
end
