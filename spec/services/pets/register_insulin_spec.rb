require 'rails_helper'

describe Pets::RegisterInsulin, type: :service do
  let!(:user) { create(:user) }
  let!(:decoded_token) { { user_id: user.id } }
  let!(:pet) {

    pet = create(:pet)
    create(:pet_owner, owner: user, pet: pet, ownership_level: 'OWNER')
    pet
  }

  let!(:params) do
    {
      pet_id: pet.id,
      glucose_level: 100,
      insulin_units: 2,
      application_time: "2024-03-13T14:00",
      observations: 'Some observations'
    }
  end

  context 'when the user has permission to register insulin' do
    it 'creates a new insulin application' do
      expect do
        described_class.call(decoded_token, params)
      end.to change { InsulinApplication.count }.by(1)
    end

    it 'returns the created insulin instance' do
      result = described_class.call(decoded_token, params).result
      expect(result).to be_a(InsulinApplication)
    end

    context 'when the user ownership is CARETAKER' do
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
      end
      it 'creates a new insulin application' do
        expect do
          described_class.call(decoded_token, params)
        end.to change { InsulinApplication.count }.by(1)
      end
    end

    context 'when the user don\'t send observations param' do
      before do
        params.delete(:observations)
      end
      it 'creates a new insulin application' do
        expect do
          described_class.call(decoded_token, params)
        end.to change { InsulinApplication.count }.by(1)
      end
    end
  end

  context 'when the user does not have permission to register insulin' do
    before do
      pet = create(:pet)
      params[:pet_id] = pet.id
    end
    it 'raises a PetPermissionError' do
      expect do
        described_class.call(decoded_token, params)
      end.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  context 'when the pet does not exist' do
    before do
      params[:pet_id] = 0
    end
    it 'raises a NotFoundError' do
      expect do
        described_class.call(decoded_token, params)
      end.to raise_error(Exceptions::NotFoundError)
    end
  end

  context 'when the user does not exist' do
    before do
      decoded_token[:user_id] = 0
    end
    it 'raises a UnauthorizedError' do
      expect do
        described_class.call(decoded_token, params)
      end.to raise_error(Exceptions::UnauthorizedError)
    end
  end
end
