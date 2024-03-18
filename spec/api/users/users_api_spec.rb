require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:token) {
    Jwt::Encode.call(user_id: user.id).result
  }

  describe 'POST api/v1/users/push_token' do
    let(:params) {
      {
        token: SecureRandom.hex(12)
      }
    }

    context 'when the user is authenticated' do
      it 'creates a new push token' do
        expect {
          post '/api/v1/users/push_token', params: params, headers: { 'Authorization' => "Bearer #{token}" }
        }.to change(PushToken, :count).by(1)
      end

      it 'returns the push token' do
        post '/api/v1/users/push_token', params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:created)
        expect(response.body).to include(params[:token])
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized error' do
        post '/api/v1/users/push_token', params: params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end