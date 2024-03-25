require 'rails_helper'

describe Pets::InsulinApplicationAPI, type: :request do
  let!(:user) { create(:user) }
  let!(:decoded_token) {
    { user_id: user.id }
  }

  let!(:token) {
    Jwt::Encode.call(user_id: user.id).result
  }

  let!(:pet) {
    pet = create(:pet)
    create(:pet_owner, owner: user, pet: pet, ownership_level: 'OWNER')
    pet
  }

  let!(:params) {
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

  context 'GET /pets/:pet_id/insulin_applications/filters' do
    let!(:insulin_application) { create(:insulin_application, pet: pet, user: user) }
    let!(:insulin_application2) { create(:insulin_application, pet: pet, user: user) }

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get "/api/v1/pets/#{pet.id}/insulin_applications/filters"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the pet does not exist' do
      it 'returns not found' do
        get "/api/v1/pets/0/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user does not have permission to access the pet' do
      let(:other_pet) { create(:pet) }
      it 'returns unauthorized' do
        get "/api/v1/pets/#{other_pet.id}/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when other pets have insulin applications' do
      before do
        create(:insulin_application,
               pet: create(:pet),
               application_time: insulin_application.application_time - 1.day,
               insulin_units: insulin_application.insulin_units - 1,
               glucose_level: insulin_application.glucose_level - 1)

        create(:insulin_application,
               pet: create(:pet),
               application_time: insulin_application2.application_time + 1.day,
               insulin_units: insulin_application2.insulin_units + 1,
               glucose_level: insulin_application2.glucose_level + 1)
      end

      it 'returns the filters' do
        get "/api/v1/pets/#{pet.id}/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq(
                          'min_date' => insulin_application.application_time.as_json,
                          'max_date' => insulin_application2.application_time.as_json,
                          'min_units' => insulin_application.insulin_units,
                          'max_units' => insulin_application2.insulin_units,
                          'min_glucose' => insulin_application.glucose_level,
                          'max_glucose' => insulin_application2.glucose_level
                        )
      end
    end

    context 'when insulin application does not exist' do
      before do
        InsulinApplication.destroy_all
      end

      it 'returns an error' do
        get "/api/v1/pets/#{pet.id}/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is a caretaker' do
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
      end

      it 'returns the filters' do
        get "/api/v1/pets/#{pet.id}/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to eq(
                          'min_date' => insulin_application.application_time.as_json,
                          'max_date' => insulin_application2.application_time.as_json,
                          'min_units' => insulin_application.insulin_units,
                          'max_units' => insulin_application2.insulin_units,
                          'min_glucose' => insulin_application.glucose_level,
                          'max_glucose' => insulin_application2.glucose_level
                        )
      end
    end

    context 'when the user does not have permission' do
      before do
        PetOwner.destroy_all
      end

      it 'returns unauthorized' do
        get "/api/v1/pets/#{pet.id}/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'returns the filters' do
      get "/api/v1/pets/#{pet.id}/insulin_applications/filters", headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'GET /insulin_applications/:insulin_application_id' do
    let!(:insulin_application) { create(:insulin_application, pet: pet, user: user) }

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get "/api/v1/insulin_applications/#{insulin_application.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the insulin application does not exist' do
      it 'returns not found' do
        get "/api/v1/insulin_applications/0", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user does not have permission to access the insulin application' do
      let(:other_pet) { create(:pet) }
      let(:other_insulin_application) { create(:insulin_application, pet: other_pet) }
      it 'returns unauthorized' do
        get "/api/v1/insulin_applications/#{other_insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the insulin application exists' do
      it 'returns the insulin application' do
        get "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(insulin_application.id)
      end
    end

    context 'when the user is a caretaker' do
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
      end

      it 'returns the insulin application' do
        get "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(insulin_application.id)
      end
    end
  end

  context 'PUT /insulin_applications/:insulin_application_id' do
    let!(:insulin_application) { create(:insulin_application, pet: pet, user: user) }
    let!(:params) {
      {
        application_time: insulin_application.application_time.utc + 1.day,
        insulin_units: insulin_application.insulin_units + 1,
        glucose_level: insulin_application.glucose_level + 1,
        responsible_id: user.id
      }
    }

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the insulin application' do
        expect { put "/api/v1/insulin_applications/#{insulin_application.id}", params: params }.not_to change { insulin_application.reload.updated_at }
      end

      it 'does not update the insulin application attributes' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params
        expect(insulin_application.reload.application_time).not_to eq(params[:application_time])
        expect(insulin_application.reload.insulin_units).not_to eq(params[:insulin_units])
        expect(insulin_application.reload.glucose_level).not_to eq(params[:glucose_level])
      end
    end

    context 'when the insulin application does not exist' do
      it 'returns not found' do
        put "/api/v1/insulin_applications/0", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end

      it 'does not update the insulin application' do
        expect { put "/api/v1/insulin_applications/0", params: params, headers: { 'Authorization ' => "Bearer #{token}" } }.not_to change { insulin_application.reload.updated_at }
      end

      it 'does not update the insulin application attributes' do
        put "/api/v1/insulin_applications/0", params: params, headers: { 'Authorization ' => "Bearer #{token}" }
        expect(insulin_application.reload.application_time).not_to eq(params[:application_time])
        expect(insulin_application.reload.insulin_units).not_to eq(params[:insulin_units])
        expect(insulin_application.reload.glucose_level).not_to eq(params[:glucose_level])
      end
    end

    context 'when the user is not the pet owner' do
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).destroy_all
      end

      it 'returns unauthorized' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the insulin application' do
        expect do
          put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        end.not_to change { insulin_application.reload.updated_at }
      end

      it 'does not update the insulin application attributes' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(insulin_application.reload.application_time).not_to eq(params[:application_time])
        expect(insulin_application.reload.insulin_units).not_to eq(params[:insulin_units])
        expect(insulin_application.reload.glucose_level).not_to eq(params[:glucose_level])
      end
    end

    context 'when the insulin application exists' do
      it 'returns the insulin application' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(insulin_application.id)
      end

      it 'updates the insulin application' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(insulin_application.reload.application_time).to eq(params[:application_time])
        expect(insulin_application.reload.insulin_units).to eq(params[:insulin_units])
        expect(insulin_application.reload.glucose_level).to eq(params[:glucose_level])
      end

      it 'updates the insulin application attributes' do
        put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        expect(insulin_application.reload.application_time).to eq(params[:application_time])
        expect(insulin_application.reload.insulin_units).to eq(params[:insulin_units])
        expect(insulin_application.reload.glucose_level).to eq(params[:glucose_level])
      end

      context 'when the user is a caretaker' do
        before do
          PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
        end

        it 'returns the insulin application' do
          put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body["id"]).to eq(insulin_application.id)
        end

        it 'updates the insulin application' do
          put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          expect(insulin_application.reload.application_time).to eq(params[:application_time])
          expect(insulin_application.reload.insulin_units).to eq(params[:insulin_units])
          expect(insulin_application.reload.glucose_level).to eq(params[:glucose_level])
        end

        it 'updates the insulin application attributes' do
          put "/api/v1/insulin_applications/#{insulin_application.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          expect(insulin_application.reload.application_time).to eq(params[:application_time])
          expect(insulin_application.reload.insulin_units).to eq(params[:insulin_units])
          expect(insulin_application.reload.glucose_level).to eq(params[:glucose_level])
        end
      end
    end
  end

  context 'DELETE /insulin_applications/:insulin_application_id' do
    let!(:insulin_application) { create(:insulin_application, pet: pet) }

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        delete "/api/v1/insulin_applications/#{insulin_application.id}"
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not delete the insulin application' do
        expect { delete "/api/v1/insulin_applications/#{insulin_application.id}" }.not_to change { InsulinApplication.count }
      end
    end

    context 'when the insulin application does not exist' do
      it 'returns not found' do
        delete "/api/v1/insulin_applications/0", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:not_found)
      end

      it 'does not delete the insulin application' do
        expect { delete "/api/v1/insulin_applications/0", headers: { 'Authorization' => "Bearer #{token}" } }.not_to change { InsulinApplication.count }
      end
    end

    context 'when the user is not the pet owner' do
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).destroy_all
      end

      it 'returns unauthorized' do
        delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not delete the insulin application' do
        expect { delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" } }.not_to change { InsulinApplication.count }
      end
    end

    context 'when the insulin application exists' do
      it 'returns ok' do
        delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
      end

      it 'deletes the insulin application' do
        expect { delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" } }.to change { InsulinApplication.count }.by(-1)
      end

      context 'when the user is a caretaker' do
        before do
          PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
        end

        it 'returns ok' do
          delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:ok)
        end

        it 'deletes the insulin application' do
          expect { delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" } }.to change { InsulinApplication.count }.by(-1)
        end
      end

      context 'when the user is an owner' do
        it 'returns ok' do
          delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" }
          expect(response).to have_http_status(:ok)
        end

        it 'deletes the insulin application' do
          expect { delete "/api/v1/insulin_applications/#{insulin_application.id}", headers: { 'Authorization' => "Bearer #{token}" } }.to change { InsulinApplication.count }.by(-1)
        end
      end
    end
  end
end