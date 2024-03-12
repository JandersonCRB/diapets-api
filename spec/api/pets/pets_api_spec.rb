require 'rails_helper'

RSpec.describe "Pets API", type: :request do
  let(:user) { create(:user) }
  let(:decoded_token) {
    { user_id: user.id }
  }

  let(:token) {
    Jwt::Encode.call(user_id: user.id).result
  }

  let(:params) {
    {}
  }

  describe 'GET api/v1/pets' do
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
end