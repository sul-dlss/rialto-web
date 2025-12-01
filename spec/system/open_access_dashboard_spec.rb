# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show open access pages' do
  let(:name) { 'Awesome Dude' }
  let(:tableau_url) { "#{Settings.tableau.base_url}#{Settings.tableau.dashboard_base_path}OpenAccess/" }

  context 'when user is logged in but is not in the business case workgroup' do
    let(:user) { create(:user, name:) }

    before do
      sign_in(user)
    end

    it 'shows the open access stanford overview viz in tab' do
      visit open_access_dashboard_path

      expect(page).to have_content('Open Access Dashboard')
      within('#stanford-overview-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}StanfordOverview\"]")
      end
    end

    it 'shows the open access schools and departments viz in tab' do
      visit open_access_dashboard_path(tab: 'department-details')
      within('#department-details-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}DepartmentDetails\"]")
      end
    end

    it 'does show the open access school overview viz in tab' do
      visit open_access_dashboard_path(tab: 'school-overview')
      within('#school-overview-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}SchoolOverview\"]")
      end
    end

    it 'does show the open access school details viz in tab' do
      visit open_access_dashboard_path(tab: 'school-details')
      within('#school-details-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}SchoolDetails\"]")
      end
    end
  end

  context 'when user is logged in and is in the business case workgroup' do
    let(:user) { create(:user, name:) }
    let(:workgroup_name) { Settings.authorization_workgroup_names.rialto }

    before do
      sign_in(user, groups: [workgroup_name])
    end

    it 'shows the open access school overview viz in tab' do
      visit open_access_dashboard_path(tab: 'school-overview')
      within('#school-overview-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}SchoolOverview\"]")
      end
    end
  end

  context 'when user is not logged in' do
    before do
      visit logout_path
    end

    it 'shows the open access stanford overview viz in tab' do
      visit open_access_dashboard_path

      expect(page).to have_content('Open Access Dashboard')
      within('#stanford-overview-frame') do
        expect(page).to have_css("#tableau-viz[src=\"#{tableau_url}StanfordOverview\"]")
      end
    end

    it 'does not show the open access department details viz in tab' do
      visit open_access_dashboard_path(tab: 'department-details')
      within('#department-details-frame') do
        expect(page).to have_no_css('#tableau-viz')
      end
      expect(page).to have_content('This page is only available to Stanford-affiliated users.')
    end

    it 'does not show the open access school overview viz in tab' do
      visit open_access_dashboard_path(tab: 'school-overview')
      within('#school-overview-frame') do
        expect(page).to have_no_css('#tableau-viz')
      end
      expect(page).to have_content('This page is only available to Stanford-affiliated users.')
    end

    it 'does not show the open access school details viz in tab' do
      visit open_access_dashboard_path(tab: 'school-details')
      within('#school-details-frame') do
        expect(page).to have_no_css('#tableau-viz')
      end
      expect(page).to have_content('This page is only available to Stanford-affiliated users.')
    end
  end
end
