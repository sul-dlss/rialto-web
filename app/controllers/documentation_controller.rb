# frozen_string_literal: true

# DocumentationController
class DocumentationController < ApplicationController
  skip_verify_authorized

  def show # rubocop:disable Metrics/MethodLength
    case params[:faq]
    when 'open-access'
      render 'open-access'
    when 'orcid-adoption'
      render 'orcid-adoption'
    when 'publications'
      render 'publications'
    when 'downloads'
      render 'downloads'
    when 'organization-data'
      render 'organization-data'
    end
  end
end
