require 'rails_helper'

RSpec.describe InsulinApplications::FindOne, type: :service do
  let!(:user) { create(:user) }
  let!(:pet) { create(:pet) }
  let!(:insulin_application) { create(:insulin_application, pet: pet) }
  let!(:pet_owner) { create(:pet_owner, owner: user, pet: pet) }
  let!(:params) { { insulin_application_id: insulin_application.id } }
  let!(:decoded_token) { { user_id: user.id } }

  subject { described_class.call(decoded_token, params).result }

  context 'when the insulin application exists' do
    it 'returns the insulin application' do
      expect(subject).to eq(insulin_application)
    end

    it 'returns the insulin application with the correct attributes' do
      expect(subject.id).to eq(insulin_application.id)
      expect(subject.pet_id).to eq(insulin_application.pet_id)
      expect(subject.application_time).to eq(insulin_application.application_time)
      expect(subject.insulin_units).to eq(insulin_application.insulin_units)
      expect(subject.glucose_level).to eq(insulin_application.glucose_level)
    end

    it 'returns the insulin application with the correct associations' do
      expect(subject.pet).to eq(insulin_application.pet)
    end

    it 'returns the insulin application with the correct timestamps' do
      expect(subject.created_at).to eq(insulin_application.created_at)
      expect(subject.updated_at).to eq(insulin_application.updated_at)
    end

    it 'returns the insulin application with the correct user permissions' do
      expect(subject.user).to eq(insulin_application.user)
    end

    context 'when the user is not the pet owner' do
      before do
        pet_owner.destroy
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Exceptions::UnauthorizedError)
      end
    end

    context 'when the insulin application does not exist' do
      let!(:params) { { insulin_application_id: 0 } }

      it 'raises an error' do
        expect { subject }.to raise_error(Exceptions::NotFoundError)
      end
    end
  end
end