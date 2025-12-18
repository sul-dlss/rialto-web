# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show home page' do
  let(:name) { 'Awesome Dude' }

  context 'when user is logged in' do
    let(:user) { create(:user, name:) }

    before do
      sign_in(user)
    end

    it 'shows the home page with logged in message' do
      get '/'

      expect(response.body).to include('aside')
      expect(response.body).to include("Logged in: #{name}")
    end
  end

  context 'when user is not logged in' do
    it 'shows the home page' do
      get '/'

      expect(response.body).to include('aside')
      expect(response.body).not_to include("Logged in: #{name}")
    end
  end
end
