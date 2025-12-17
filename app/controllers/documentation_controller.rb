# frozen_string_literal: true

# DocumentationController
class DocumentationController < ApplicationController
  skip_verify_authorized

  def show
    case params[:faq]
    when 'open-access'
      render 'open-access'
    when 'orcid-adoption'
      render 'orcid-adoption'
    when 'publications'
      render 'publications'
    when 'downloads'
      render 'downloads'
    end
  end
end
