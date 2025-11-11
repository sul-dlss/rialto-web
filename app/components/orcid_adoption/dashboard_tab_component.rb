# frozen_string_literal: true

module OrcidAdoption
  # Show the tabs above the orcid adoption dashboard embed
  class DashboardTabComponent < ApplicationComponent
    attr_reader :tab_classes, :selected_tab

    delegate :authenticated?, :allowed_to?, to: :helpers

    def initialize(selected_tab: 'overview')
      super()
      @selected_tab = selected_tab
    end

    # a hash of the name of the tab and the text to be shown
    def tabs
      {
        'overview' => 'Stanford Overview',
        'schools' => 'Schools and Departments',
        'researchers' => 'Individual Researchers'
      }
    end
  end
end
