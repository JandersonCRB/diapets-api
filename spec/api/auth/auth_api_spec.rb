require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  describe 'POST /auth/login' do
    let(:user) { create(:user, email: 'johndoe@example.com', password: 'password') }
    let(:params) { { email: user.email, password: user.password } }

    context 'when user is found' do
      context 'when password is valid' do
        it 'returns a token' do
          post '/api/v1/auth/login', params: params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('token')
        end
      end

      context 'when password is invalid' do
        it 'returns an error' do
          params[:password] = 'invalid_password'
          post '/auth/login', params: params
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to include('Invalid credentials')
        end
      end

      context 'when JWT_SECRET ENV variable is not set' do
        it 'returns an error' do
          allow(ENV).to receive(:fetch).with('JWT_SECRET').and_return(nil)
          post '/auth/login', params: params
          expect(response).to have_http_status(:internal_server_error)
          expect(response.body).to include('Internal server error')
        end
      end
    end
  end
end