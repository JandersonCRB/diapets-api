require 'rails_helper'

RSpec.describe Pets::FindAllByUser do
  let(:user) { create(:user) }
  let(:decoded_token) {
    { user_id: user.id }
  }

  let(:params) {
    {}
  }

  describe 'regarding pets' do

    context 'when user has pets' do
      let!(:pet) {
        pet = create(:pet)
        pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
        pet
      }

      context 'when has only one pet' do
        it 'returns all pets for the user' do
          pets = described_class.call(decoded_token, params).result

          expect(pets).to eq([pet])
        end
      end

      context 'when has more than one pet' do
        let!(:other_pet) {
          other_pet = create(:pet)
          other_pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
          other_pet
        }

        it 'returns all pets for the user' do
          pets = described_class.call(decoded_token, params).result

          expect(pets).to eq([pet, other_pet])
        end
      end

      context 'when user has one pet as OWNER and other as CARETAKER' do
        let!(:caretaker_pet) {
          caretaker_pet = create(:pet)
          caretaker_pet.pet_owners.create(owner: user, ownership_level: 'CARETAKER')
          caretaker_pet
        }

        it 'returns all pets for the user' do
          pets = described_class.call(decoded_token, params).result

          expect(pets).to eq([pet, caretaker_pet])
        end
      end

      context 'when user has one pet as OWNER and other as CARETAKER and other pet as OWNER' do
        let!(:caretaker_pet) {
          caretaker_pet = create(:pet)
          caretaker_pet.pet_owners.create(owner: user, ownership_level: 'CARETAKER')
          caretaker_pet
        }
        let!(:other_owner_pet) {
          other_owner_pet = create(:pet)
          other_owner_pet.pet_owners.create(owner: user, ownership_level: 'OWNER')
          other_owner_pet
        }

        it 'returns all pets for the user' do
          pets = described_class.call(decoded_token, params).result

          expect(pets).to eq([pet, caretaker_pet, other_owner_pet])
        end
      end

      context 'when pet has more than one owner' do
        let(:other_user) { create(:user) }

        before do
          pet.pet_owners.create(owner: other_user, ownership_level: 'CARETAKER')
        end

        it 'returns all pets for the user' do
          pets = described_class.call(decoded_token, params).result

          expect(pets).to eq([pet])
        end

        it 'returns all the owners for the pet' do
          pets = described_class.call(decoded_token, params).result

          expect(pets.first.owners).to eq([user, other_user])
        end
      end

      context 'when user has pets and there are other pets' do
        let!(:other_user) { create(:user) }
        let!(:other_pet) {
          other_pet = create(:pet)
          other_pet.pet_owners.create(owner: other_user, ownership_level: 'OWNER')
          other_pet
        }

        it 'returns all pets for the user' do
          pets = described_class.call(decoded_token, params).result

          expect(pets).to eq([pet])
        end
      end
    end

    context 'when user does not have pets' do
      it 'returns an empty array' do
        pets = described_class.call(decoded_token, params).result

        expect(pets).to eq([])
      end
    end
  end

  describe 'regarding user' do
    context 'when user does not exist' do
      let(:decoded_token) {
        { user_id: 0 }
      }

      it 'raises an error' do
        expect {
          described_class.call(decoded_token, params).result
        }.to raise_error(Exceptions::InternalServerError, 'User not found')
      end
    end
  end
end