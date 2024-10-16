require 'rails_helper'

RSpec.describe "Pets API", type: :request do
  let(:user) { create(:user) }
  let(:decoded_token) {
    { user_id: user.id }
  }

  let(:token) {
    Jwt::Encode.call(user_id: user.id).result
  }

  describe 'GET api/v1/pets' do
    let(:params) {
      {}
    }
    context 'when user is authenticated' do
      context 'when user has pets' do
        let!(:pet) {
          pet = create(:pet)
          pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
          pet
        }

        context 'when has only one pet' do
          it 'returns all pets for the user' do
            get '/api/v1/pets', headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(pet.name)
          end
        end

        context 'when has more than one pet' do
          let!(:other_pet) {
            other_pet = create(:pet)
            other_pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
            other_pet
          }

          it 'returns all pets for the user' do
            get '/api/v1/pets', headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(pet.name)
            expect(response.body).to include(other_pet.name)
          end
        end

        context 'when user has one pet as OWNER and other as CARETAKER' do
          let!(:caretaker_pet) {
            caretaker_pet = create(:pet)
            caretaker_pet.pet_owners.create(owner: user, ownership_level: 'CARETAKER')
            caretaker_pet
          }

          it 'returns all pets for the user' do
            get '/api/v1/pets', headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(pet.name)
            expect(response.body).to include(caretaker_pet.name)
          end
        end

        context 'when user has one pet as OWNER and other as CARETAKER and other pet as OWNER' do
          let!(:caretaker_pet) {
            caretaker_pet = create(:pet)
            caretaker_pet.pet_owners.create(owner: user, ownership_level: 'CARETAKER')
            caretaker_pet
          }

          let!(:other_pet) {
            other_pet = create(:pet)
            other_pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
            other_pet
          }

          it 'returns all pets for the user' do
            get '/api/v1/pets', headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(pet.name)
            expect(response.body).to include(caretaker_pet.name)
            expect(response.body).to include(other_pet.name)
          end
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401' do
        get '/api/v1/pets'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST api/v1/pets/:id/insulin_applications' do
    let(:pet) {
      pet = create(:pet)
      pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
      pet
    }

    let(:params) {
      {
        glucose_level: 100,
        insulin_units: 2,
        responsible_id: user.id,
        application_time: "2024-03-13T14:00",
        observations: 'Some observations'
      }
    }

    context 'when the user does not authenticate' do
      it 'returns 401' do
        post "/api/v1/pets/#{pet.id}/insulin_applications", params: params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user authenticate' do
      context 'when the user has permission to register insulin' do
        it 'creates a new insulin application' do
          post "/api/v1/pets/#{pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:created)
          expect(response.body).to include('Some observations')
        end

        context 'when the user don\'t send observations param' do
          before do
            params.delete(:observations)
          end
          it 'creates a new insulin application' do
            post "/api/v1/pets/#{pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:created)
          end
        end

        context 'when the user ownership is CARETAKER' do
          before do
            pet.pet_owners.update(ownership_level: 'CARETAKER')
          end
          it 'creates a new insulin application' do
            post "/api/v1/pets/#{pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:created)
            expect(response.body).to include('Some observations')
          end
        end

        context 'when the user does not send the glucose_level param' do
          before do
            params.delete(:glucose_level)
          end
          it 'returns 400' do
            post "/api/v1/pets/#{pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when the user does not send the insulin_units param' do
          before do
            params.delete(:insulin_units)
          end
          it 'returns 400' do
            post "/api/v1/pets/#{pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when the user does not send the application_time param' do
          before do
            params.delete(:application_time)
          end
          it 'returns 400' do
            post "/api/v1/pets/#{pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:bad_request)
          end
        end
      end

      context 'when the user does not have permission to register insulin' do
        let(:other_pet) {
          create(:pet)
        }

        it 'returns 401' do
          post "/api/v1/pets/#{other_pet.id}/insulin_applications", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  context 'GET /api/v1/pets/:id/dashboard' do
    let(:pet) {
      pet = create(:pet)
      pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
      pet
    }

    let!(:insulin_application) {
      create(:insulin_application, pet: pet, user: user)
    }

    let(:params) {
      {}
    }

    context 'when the user does not authenticate' do
      it 'returns 401' do
        get "/api/v1/pets/#{pet.id}/dashboard"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user authenticate' do
      context 'when the user has permission to access the pet' do
        it 'returns the pet dashboard' do
          get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body['last_insulin_application']['id']).to eq(insulin_application.id)
        end

        context 'when there is no insulin application for the pet' do
          before do
            InsulinApplication.all.destroy_all
          end
          it 'returns nil for last insulin application' do
            get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body['last_insulin_application']).to be_nil
          end

          it 'returns nil for next insulin application' do
            get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body['next_insulin_application']).to be_nil
          end
        end

        context 'when there are many insuline applications for multiple pets' do
          let!(:other_pet) {
            other_pet = create(:pet)
            other_pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
            other_pet
          }
          let!(:insulin_applications) {
            create_list(:insulin_application, 5, pet: other_pet, user: user)
          }

          it 'returns the last insulin application' do
            get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body['last_insulin_application']['id']).to eq(InsulinApplication.where(pet_id: pet.id).order(application_time: :desc).first&.id)
          end

          it 'returns the next insulin application' do
            get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body['next_insulin_application'].to_datetime).to eq(insulin_application.application_time.advance(hours: pet.insulin_frequency))
          end
        end

        context 'when there are many insulin applications for the pet' do
          let!(:insulin_applications) {
            create_list(:insulin_application, 5, pet: pet, user: user)
          }

          it 'returns the last insulin application' do
            get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body['last_insulin_application']['id']).to eq(InsulinApplication.where(pet_id: pet.id).order(application_time: :desc).first&.id)
          end

          it 'returns the next insulin application' do
            get "/api/v1/pets/#{pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:ok)
            body = JSON.parse(response.body)
            expect(body['next_insulin_application'].to_datetime).to eq(insulin_applications.last.application_time.advance(hours: pet.insulin_frequency))
          end
        end

        context 'when the pet does not exist' do
          it 'returns 404' do
            get "/api/v1/pets/0/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'when the user does not have permission to access the pet' do
        let(:other_pet) {
          create(:pet)
        }

        it 'returns 401' do
          get "/api/v1/pets/#{other_pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when the pet does not exist' do
      it 'returns 404' do
        get "/api/v1/pets/0/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user does not have permission to access the pet' do
      let(:other_pet) {
        create(:pet)
      }

      it 'returns 401' do
        get "/api/v1/pets/#{other_pet.id}/dashboard", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'POST /api/v1/pets' do
    let(:params) {
      {
        name: 'Rex',
        species: 'DOG',
        birthdate: '2020-01-01',
        insulin_frequency: 12
      }
    }

    context 'when name is short' do
      before do
        params[:name] = 'R'
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when name is too big' do
      before do
        params[:name] = 'R' * 51
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when species is invalid' do
      before do
        params[:species] = 'INVALID_SPECIES'
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when birthdate is invalid' do
      before do
        params[:birthdate] = 'INVALID_BIRTHDATE'
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when birthdate is in the future' do
      before do
        params[:birthdate] = Date.today.advance(days: 1).to_s
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
      end
    end

    context 'when insulin_frequency is invalid' do
      before do
        params[:insulin_frequency] = 'INVALID_INSULIN_FREQUENCY'
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when insulin_frequency is negative' do
      before do
        params[:insulin_frequency] = -1
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
      end
    end

    context 'when insulin_frequency is zero' do
      before do
        params[:insulin_frequency] = 0
      end

      it 'returns 400' do
        post '/api/v1/pets', params: params, headers: { 'Authorization ' => "Bearer #{token}" }
      end
    end
  end
end