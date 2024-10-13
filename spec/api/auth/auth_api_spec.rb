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
          post '/api/v1/auth/login', params: params
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to include('Invalid credentials')
        end
      end

      context 'when JWT_SECRET ENV variable is not set' do
        it 'returns an error' do
          allow(ENV).to receive(:fetch).with('JWT_SECRET', nil).and_return(nil)
          post '/api/v1/auth/login', params: params
          expect(response).to have_http_status(:internal_server_error)
        end
      end
    end
  end

  describe 'GET /auth/user' do
    let(:user) { create(:user) }
    let(:token) { Jwt::Encode.call({ user_id: user.id }).result }

    context 'when user is found' do
      it 'returns a user' do
        get '/api/v1/auth/user', headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['id']).to eq(user.id)
        expect(body['email']).to eq(user.email)
      end
    end

    context 'when user is not found' do
      it 'returns an error' do
        get '/api/v1/auth/user', headers: { 'Authorization' => "Bearer invalid_token" }
        body = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(body['error_code']).to eq(ErrorCodes::CODES[:INVALID_TOKEN])
      end
    end
  end

  describe 'POST /auth/user' do
    let(:params) do
      {
        email: 'johndoe@example.com',
        password: 'password',
        first_name: 'John',
        last_name: 'Doe'
      }
    end

    context 'when user is created successfully' do
      it 'returns a token' do
        post '/api/v1/auth/user', params: params
        expect(response).to have_http_status(:created)
        expect(response.body).to include('token')
      end

      it 'returns a user' do
        post '/api/v1/auth/user', params: params
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['user']['email']).to eq(params[:email])
        expect(body['user']['first_name']).to eq(params[:first_name])
        expect(body['user']['last_name']).to eq(params[:last_name])
      end
    end

    describe 'user failed' do
      context 'when email is already taken' do
        before do
          create(:user, email: params[:email])
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Email is already taken')
          expect(response.body).to include('EMAIL_TAKEN')
        end
      end

      context 'when email is blank' do
        before do
          params[:email] = ''
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Email is required')
          expect(response.body).to include('EMAIL_REQUIRED')
        end
      end

      context 'when email is invalid' do
        before do
          params[:email] = 'invalid_email'
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Email is invalid')
        end
      end

      context 'when password is too short' do
        before do
          params[:password] = 'short'
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Password is too short')
        end
      end

      context 'when first name is blank' do
        before do
          params[:first_name] = ''
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('First name is required')
        end
      end

      context 'when first name is too short' do
        before do
          params[:first_name] = 'a'
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('First name is too short')
          expect(response.body).to include('FIRST_NAME_SHORT')
        end
      end

      context 'when last name is blank' do
        before do
          params[:last_name] = ''
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Last name is required')
          expect(response.body).to include('LAST_NAME_REQUIRED')
        end
      end

      context 'when last name is too short' do
        before do
          params[:last_name] = 'a'
        end

        it 'returns an error' do
          post '/api/v1/auth/user', params: params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Last name is too short')
          expect(response.body).to include('LAST_NAME_SHORT')
        end
      end
    end

    describe 'user created' do
      it 'creates a user' do
        expect do
          post '/api/v1/auth/user', params: params
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it 'returns a token' do
        post '/api/v1/auth/user', params: params
        expect(response).to have_http_status(:created)
        expect(response.body).to include('token')
      end

      it 'returns a user' do
        post '/api/v1/auth/user', params: params
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['user']['email']).to eq(params[:email])
        expect(body['user']['first_name']).to eq(params[:first_name])
        expect(body['user']['last_name']).to eq(params[:last_name])
      end
    end
  end
end