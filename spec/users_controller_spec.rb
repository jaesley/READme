require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }

  before(:each) { sign_in user }

  describe '#show' do
    before(:each) { get :show, params: { id: user.id } }

    it 'returns a status of 200' do
      expect(response).to have_http_status 200
    end

    it 'assigns @user' do
      expect(assigns[:user]).to eq user
    end

    it 'renders the users#show view' do
      expect(response).to render_template :show
    end
  end
