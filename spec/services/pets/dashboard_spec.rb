require 'rails_helper'

describe Pets::Dashboard, type: :service do
  let!(:user) { create(:user) }
  let!(:decoded_token) { { user_id: user.id } }
  let!(:pet) {
    pet = create(:pet)
    create(:pet_owner, owner: user, pet: pet, ownership_level: 'OWNER')
    pet
  }

  let!(:params) do
    {
      pet_id: pet.id
    }
  end

  context 'when there is one insulin application for the pet' do
    let!(:insulin_application) {
      create(:insulin_application, pet: pet, user: user)
    }
    it 'returns the last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:last_insulin_application]).to eq(insulin_application)
    end

    it 'returns the next insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:next_insulin_application]).to eq(insulin_application.application_time.advance(hours: pet.insulin_frequency))
    end

    context 'when the user register an application for another user' do
      let!(:other_user) { create(:user) }
      let!(:insulin_application) {
        create(:insulin_application, pet: pet, user: other_user)
      }
      before do
        create(:pet_owner, owner: other_user, pet: pet, ownership_level: 'CARETAKER')
      end

      it 'returns the last insulin application' do
        result = described_class.call(decoded_token, params).result
        expect(result[:last_insulin_application]).to eq(insulin_application)
      end
    end

    context 'when the user is a caretaker' do
      before do
        PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
      end
      it 'returns the last insulin application' do
        result = described_class.call(decoded_token, params).result
        expect(result[:last_insulin_application]).to eq(insulin_application)
      end
    end
  end

  context 'when there is no insulin application for the pet' do
    it 'returns nil for last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:last_insulin_application]).to be_nil
    end

    it 'returns nil for next insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:next_insulin_application]).to be_nil
    end
  end

  context 'when there are many insulin applications for the pet' do
    let!(:insulin_applications) {
      create_list(:insulin_application, 5, pet: pet, user: user)
    }

    it 'returns the last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:last_insulin_application]).to eq(InsulinApplication.where(pet_id: pet.id).order(application_time: :desc).first)
    end

    it 'returns the next insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:next_insulin_application]).to eq(insulin_applications.last.application_time.advance(hours: pet.insulin_frequency))
    end
  end

  context 'when there are many insuline applications for multiple pets' do
    let!(:other_pet) {
      other_pet = create(:pet)
      create(:pet_owner, owner: user, pet: other_pet, ownership_level: 'OWNER')
      other_pet
    }
    let!(:insulin_applications) {
      create_list(:insulin_application, 5, pet: other_pet, user: user)
    }

    let!(:insulin_application) {
      create(:insulin_application, pet: pet, user: user)
    }

    it 'returns the last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:last_insulin_application]).to eq(InsulinApplication.where(pet_id: pet.id).order(application_time: :desc).first)
    end

    it 'returns the next insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result[:next_insulin_application]).to eq(InsulinApplication.where(pet_id: pet.id).order(application_time: :desc).first.application_time.advance(hours: other_pet.insulin_frequency))
    end
  end

  context 'when the pet does not exist' do
    let!(:params) do
      {
        pet_id: 0
      }
    end
    it 'raises a not found error' do
      expect do
        described_class.call(decoded_token, params)
      end.to raise_error(Exceptions::NotFoundError)
    end
  end

  context 'when the user does not have permission to access the pet' do
    let!(:pet) { create(:pet) }
    let!(:params) do
      {
        pet_id: pet.id
      }
    end
    it 'raises an unauthorized error' do
      expect do
        described_class.call(decoded_token, params)
      end.to raise_error(Exceptions::UnauthorizedError)
    end
  end
end