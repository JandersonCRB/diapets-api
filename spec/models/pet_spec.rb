require 'rails_helper'

describe Pet, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      pet = create(:pet)
      expect(pet).to be_valid
    end

  it 'is not valid without a name' do
      pet = build(:pet, name: nil)
      expect(pet).to_not be_valid
    end
  end

  describe 'associations' do
    it 'has many insulin_applications' do
      pet = create(:pet)
      expect(pet.insulin_applications).to be_empty
    end

    it 'has many pet_owners' do
      pet = create(:pet)
      expect(pet.pet_owners).to be_empty
    end

    it 'has many owners' do
      pet = create(:pet)
      expect(pet.owners).to be_empty
    end
  end
end