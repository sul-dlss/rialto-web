# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Publications' do
  describe 'GET /index' do
    context 'when user is not logged in' do
      it 'returns login alert' do
        get '/download'
        expect(response).to have_http_status(:success)
        expect(response.body).to include 'This page is only available to Stanford-affiliated users.'
      end

      it 'returns unauthorized for no user' do
        get '/download/author'
        expect(response.body).to eq '{"error":"Not logged in"}'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns not found' do
        get '/download/made_up'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is logged in without correct permissions' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'returns page info' do
        get '/download'
        expect(response).to have_http_status(:success)
        expect(response.body).to include 'This page is only available to select users.'
      end

      it 'returns unauthorized' do
        get '/download/author'
        expect(response.body).to eq '{"error":"Unauthorized user"}'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns failure' do
        get '/download/made_up'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is logged in with correct permissions' do
      let(:user) { create(:user) }
      let(:workgroup_name) { Settings.authorization_workgroup_names.rialto }

      before do
        sign_in(user, groups: [workgroup_name])
      end

      it 'returns page info' do
        get '/download'
        expect(response).to have_http_status(:success)
        expect(response.body).to include 'publications_by_department.zip'
        expect(response.body).to include('aria-label="Download publications.zip"')
      end

      it 'returns success' do
        get '/download/pubs'
        expect(response).to have_http_status(:success)
      end

      it 'returns not found' do
        get '/download/made_up'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
