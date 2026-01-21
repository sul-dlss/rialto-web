# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Documentation page' do
  describe 'GET /show' do
    it 'returns open access documentation' do
      get documentation_url('open-access')
      expect(response).to have_http_status(:success)
      # expect(response.body).to include 'Open Access Dashboard Documentation'
    end

    it 'returns orcid adoption documentation' do
      get documentation_url('orcid-adoption')
      expect(response).to have_http_status(:success)
      # expect(response.body).to include 'ORCID iD Adoption Dashboard Documentation'
    end

    it 'returns publications documentation' do
      get documentation_url('publications')
      expect(response).to have_http_status(:success)
      # expect(response.body).to include 'Publications Dashboard'
    end

    it 'returns downloads documentation' do
      get documentation_url('downloads')
      expect(response).to have_http_status(:success)
    end

    it 'returns error' do
      expect do
        get documentation_url('publications2')
      end.to raise_error(ActionController::UrlGenerationError)
    end
  end
end
