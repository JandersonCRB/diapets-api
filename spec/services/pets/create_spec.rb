require 'rails_helper'

RSpec.describe Pets::Create do
  let(:params) {
    {
      name: 'Rex',
      species: 'DOG',
      birthdate: '2020-01-01',
      insulin_frequency: 12
    }
  }

  let(:user) {
    create(:user)
  }

  let(:decoded_token) { { user_id: user.id } }
  subject { described_class.call(decoded_token, params).result }

  describe 'name' do
    context 'when name is nil' do
      before do
        params[:name] = nil
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Name is required')
      end
    end

    context 'when name is too short' do
      before do
        params[:name] = 'R'
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Name is too short')
      end
    end

    context 'when name is too big' do
      before do
        params[:name] = 'R' * 51
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Name is too big')
      end
    end
  end

  describe 'species' do
    context 'when species is nil' do
      before do
        params[:species] = nil
      end
      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Species is required')
      end
    end

    context 'when species is invalid' do
      before do
        params[:species] = 'FISH'
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Species is invalid')
      end
    end
  end

  describe 'birthdate' do
    context 'when birthdate is nil' do
      before do
        params[:birthdate] = nil
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Birthdate is required')
      end
    end

    context 'when birthdate is invalid' do
      before do
        params[:birthdate] = 'invalid'
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Birthdate is invalid')
      end
    end

    context 'when birthdate is in the future' do
      before do
        params[:birthdate] = (Date.today + 1.day).to_s
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Birthdate is in the future')
      end
    end
  end

  describe 'insulin_frequency' do
    context 'when insulin_frequency is nil' do
      before do
        params[:insulin_frequency] = nil
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Insulin frequency is required')
      end
    end

    context 'when insulin_frequency is invalid' do
      before do
        params[:insulin_frequency] = 'invalid'
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Insulin frequency is invalid')
      end
    end

    context 'when insulin_frequency is negative' do
      before do
        params[:insulin_frequency] = -1
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Insulin frequency can not be negative')
      end
    end

    context 'when insulin_frequency is zero' do
      before do
        params[:insulin_frequency] = 0
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Insulin frequency can not be zero')
      end
    end

    context 'when insulin_frequency is too big' do
      before do
        params[:insulin_frequency] = 25
      end

      it 'returns an error' do
        expect { subject }.to raise_error(Exceptions::BadRequestError, 'Insulin frequency is too big')
      end
    end
  end

  context 'when all params are valid' do
    it 'creates a pet' do
      expect { subject }.to change { Pet.count }.by(1)
    end

    it 'creates a pet owner' do
      expect { subject }.to change { PetOwner.count }.by(1)
    end

    it 'returns the pet' do
      expect(subject).to be_a(Pet)
    end

    it 'returns the pet with the correct attributes' do
      pet = subject
      expect(pet.name).to eq('Rex')
      expect(pet.species).to eq('DOG')
      expect(pet.birthdate).to eq(Date.parse('2020-01-01'))
      expect(pet.insulin_frequency).to eq(12)
    end

    it 'returns the pet with the correct owner' do
      pet = subject
      expect(pet.pet_owners).to include(PetOwner.find_by(owner_id: decoded_token[:user_id], ))
    end

    it 'created the correct pet owner' do
      pet = subject

      pet_owners = PetOwner.where(owner_id: decoded_token[:user_id], pet_id: pet.id)
      expect(pet_owners.count).to eq(1)
    end
  end
end