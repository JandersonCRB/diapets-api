require 'rails_helper'

describe Pets::FindAllInsulinApplications, type: :service do
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
      expect(result.to_a).to eq([insulin_application])
    end
  end

  context 'when the user is a caretaker' do
    let!(:insulin_application) {
      create(:insulin_application, pet: pet, user: user)
    }
    before do
      PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
    end
    it 'returns the last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result.to_a).to eq([insulin_application])
    end
  end

  context 'when there is no insulin application for the pet' do
    it 'returns an empty array' do
      result = described_class.call(decoded_token, params).result
      expect(result.to_a).to eq([])
    end
  end

  context 'when the pet does not exist' do
    it 'raises a not found error' do
      expect {
        described_class.call(decoded_token, params.merge(pet_id: 0)).result
      }.to raise_error(Exceptions::NotFoundError)
    end
  end

  context 'when the user does not have permission to access the pet' do
    it 'raises an unauthorized error' do
      expect {
        described_class.call(decoded_token, params.merge(pet_id: create(:pet).id)).result
      }.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  context 'when the user is not authenticated' do
    it 'raises an unauthorized error' do
      expect {
        described_class.call({}, params).result
      }.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  context 'when the user is not authorized' do
    it 'raises an unauthorized error' do
      expect {
        described_class.call({ user_id: create(:user).id }, params).result
      }.to raise_error(Exceptions::UnauthorizedError)
    end
  end
end