# frozen_string_literal: true

# Controller for the public access pages, subclass as needed
class PublicController < ApplicationController
  skip_verify_authorized
  before_action :require_turbo_frame, except: [:show]

  def show
    @tabs = tabs
  end

  def stanford_overview
    @tab_key = 'stanford-overview'
    render DashboardEmbedComponent.new(embed_url:,
                                       turbo_frame_id:, authorized: true)
  end

  def school_details
    @tab_key = 'school-details'
    render DashboardEmbedComponent.new(embed_url:,
                                       turbo_frame_id:, authorized: stanford_access?)
  end

  # the schools and departments dashboard embedded view (stanford users only) -
  # turbo frame loaded only when tab is selected
  def department_details
    @tab_key = 'department-details'
    render DashboardEmbedComponent.new(embed_url:,
                                       turbo_frame_id:, token:,
                                       authorized: stanford_access?)
  end

  private

  # tabs that get passed to the DashboardTabComponent
  # a slug for these tabs, their name in tableau and the tab title are in settings.yml
  # the local routes for the turbo src variable are defined in the controller
  # this merges the two hashes together to be looped through in the DashboardTabComponent
  def tabs
    settings_tabs.to_h.deep_transform_keys(&:to_s).deep_merge(tab_routes)
  end

  def turbo_frame_id
    "#{@tab_key}-frame"
  end

  def embed_url
    "#{Settings.tableau.base_url}#{Settings.tableau.dashboard_base_path}#{tableau_group}/#{tableau_view_name}"
  end

  def tableau_view_name
    tabs[@tab_key]['tableau']
  end

  def token
    return unless current_user

    mint_jwt_token
  end
end
