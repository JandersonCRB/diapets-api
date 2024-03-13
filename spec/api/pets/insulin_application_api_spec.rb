require 'rails_helper'

describe Pets::InsulinApplicationAPI, type: :request do
  let(:user) { create(:user) }
  let(:decoded_token) {
    { user_id: user.id }
  }

  let(:token) {
    Jwt::Encode.call(user_id: user.id).result
  }

  let(:pet) {
    pet = create(:pet)
    create(:pet_owner, owner: user, pet: pet, ownership_level: 'OWNER')
    pet
  }

  let(:params) {
    {
      pet_id: pet.id
    }
  }

  context 'GET /pets/:pet_id/insulin_applications' do
    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get "/api/v1/pets/#{pet.id}/insulin_applications"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the pet does not exist' do
      it 'returns not found' do
        get "/api/v1/pets/0/insulin_applications", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user does not have permission to access the pet' do
      let(:other_pet) { create(:pet) }
      it 'returns unauthorized' do
        get "/api/v1/pets/#{other_pet.id}/insulin_applications", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when there is one insulin application for the pet' do
      let!(:insulin_application) {
        create(:insulin_application, pet: pet, user: user)
      }

      it 'returns the pet insulin applications' do
        get "/api/v1/pets/#{pet.id}/insulin_applications", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body[0]["id"]).to eq(insulin_application.id)
      end
    end

    context 'when the user is a caretaker' do
      let!(:insulin_application) {
        create(:insulin_application, pet: pet, user: user)
      }
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
      end

      it 'returns the pet insulin applications' do
        get "/api/v1/pets/#{pet.id}/insulin_applications", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body[0]["id"]).to eq(insulin_application.id)
      end
    end

    context 'when there is no insulin application for the pet' do
      it 'returns an empty array' do
        get "/api/v1/pets/#{pet.id}/insulin_applications", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq([])
        end
    end

    context 'when there are many insulin applications for the pet' do
      let!(:insulin_application) {
        create_list(:insulin_application, 92, pet: pet, user: user)
      }
      it 'returns the pet insulin applications' do
        get "/api/v1/pets/#{pet.id}/insulin_applications", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.length).to eq(92)
        (0..91).each do |i|
          expect(body[i]["id"]).to eq(insulin_application[i].id)
        end
      end
    end
  end
end