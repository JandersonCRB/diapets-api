require 'rails_helper'

RSpec.describe InsulinApplications::Delete do
  let!(:user) { create(:user) }
  let!(:pet) { create(:pet) }
  let!(:pet_owners) { create(:pet_owner, pet: pet, owner: user) }
  let!(:insulin_application) { create(:insulin_application, pet: pet) }
  let!(:decoded_token) { { user_id: user.id } }
  let!(:params) { { insulin_application_id: insulin_application.id } }

  subject { described_class.call(decoded_token, params).result }

  context 'when the insulin_application exists' do
    it 'deletes the insulin_application' do
      expect do
        subject
      end.to change { InsulinApplication.count }.by(-1)
    end
  end

  context 'when the insulin_application does not exist' do
    let(:params) { { insulin_application_id: 0 } }

    it 'does not delete the insulin_application' do
      expect do
        subject
      end.to raise_error(Exceptions::NotFoundError, 'Insulin application not found')
    end
  end

  context 'when the user is not the pet owner' do
    let(:decoded_token) { { user_id: create(:user).id } }

    it 'does not delete the insulin_application' do
      expect do
        subject
      end.to raise_error(Exceptions::UnauthorizedError)
    end
  end
end