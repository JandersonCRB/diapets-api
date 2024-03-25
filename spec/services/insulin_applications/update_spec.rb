require 'rails_helper'

RSpec.describe InsulinApplications::Update, type: :service do
  let!(:user) { create(:user) }
  let!(:pet) { create(:pet) }
  let!(:insulin_application) { create(:insulin_application, pet: pet, user: user) }
  let!(:pet_owner) { create(:pet_owner, owner: user, pet: pet) }
  let!(:decoded_token) { { user_id: user.id } }
  let!(:params) {
    {
      insulin_application_id: insulin_application.id,
      application_time: "2021-01-01 12:00:00",
      insulin_units: 2,
      glucose_level: 100,
      user_id: user.id
    }
  }

  subject { described_class.call(decoded_token, params).result }

  context 'when the insulin application exists' do
    it 'updates the insulin application' do
      expect(subject).to eq(insulin_application)
      expect(subject.application_time).to eq(params[:application_time])
      expect(subject.insulin_units).to eq(params[:insulin_units])
      expect(subject.glucose_level).to eq(params[:glucose_level])
    end

    it 'updates the insulin application with the correct attributes' do
      expect(subject.id).to eq(insulin_application.id)
      expect(subject.pet_id).to eq(insulin_application.pet_id)
      expect(subject.application_time).to eq(params[:application_time])
      expect(subject.insulin_units).to eq(params[:insulin_units])
      expect(subject.glucose_level).to eq(params[:glucose_level])
    end

    it 'updates the insulin application with the correct associations' do
      expect(subject.pet).to eq(insulin_application.pet)
    end

    it 'updates the insulin application with the correct timestamps' do
      expect(subject.created_at).to eq(insulin_application.created_at)
      expect(subject.updated_at).not_to eq(insulin_application.updated_at)
    end

    context 'when the insulin application does not exist' do
      let!(:params) { { insulin_application_id: 0 } }

      it 'raises an error' do
        expect { subject }.to raise_error(Exceptions::NotFoundError)
      end
    end

    context 'when the user is not the pet owner' do
      before do
        pet.pet_owners.destroy_all
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Exceptions::UnauthorizedError)
      end
    end

    context 'when the user is a caretaker' do
      let!(:caretaker) { create(:user) }
      let!(:pet_owner) { create(:pet_owner, owner: caretaker, pet: pet, ownership_level: 'CARETAKER') }
      let!(:decoded_token) { { user_id: caretaker.id } }

      it 'updates the insulin application' do
        expect(subject).to eq(insulin_application)
        expect(subject.application_time).to eq(params[:application_time])
        expect(subject.insulin_units).to eq(params[:insulin_units])
        expect(subject.glucose_level).to eq(params[:glucose_level])
      end

      it 'updates the insulin application with the correct attributes' do
        expect(subject.id).to eq(insulin_application.id)
        expect(subject.pet_id).to eq(insulin_application.pet_id)
        expect(subject.application_time).to eq(params[:application_time])
        expect(subject.insulin_units).to eq(params[:insulin_units])
        expect(subject.glucose_level).to eq(params[:glucose_level])
      end
    end
  end

  context 'when the insulin application does not exist' do
    let!(:params) { { insulin_application_id: 0 } }

    it 'raises an error' do
      expect { subject }.to raise_error(Exceptions::NotFoundError)
    end
  end

  context 'when the user is not authenticated' do
    let!(:decoded_token) { { user_id: nil } }

    it 'raises an error' do
      expect { subject }.to raise_error(Exceptions::UnauthorizedError)
    end
  end
end