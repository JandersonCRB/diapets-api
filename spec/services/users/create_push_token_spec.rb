require 'rails_helper'

RSpec.describe Users::CreatePushToken do
  let(:user) { create(:user) }
  let(:decoded_token) { { user_id: user.id } }
  let(:params) {
    {
      token: SecureRandom.hex(12)
    }
  }

  context 'when the push token does not exist' do
    it 'creates a new push token' do
      expect {
        described_class.call(decoded_token, params)
      }.to change(PushToken, :count).by(1)
    end

    it 'returns the push token' do
      result = described_class.call(decoded_token, params).result
      expect(result).to be_a(PushToken)
      expect(result.user).to eq(user)
      expect(result.token).to eq(params[:token])
    end
  end

  context 'when the push token already exists' do
    let!(:push_token) { create(:push_token, user: user, token: params[:token]) }

    it 'does not create a new push token' do
      expect {
        described_class.call(decoded_token, params)
      }.not_to change(PushToken, :count)
    end

    it 'returns the push token' do
      result = described_class.call(decoded_token, params).result
      expect(result).to eq(push_token)
    end

    it 'does not update the push token' do
      expect {
        described_class.call(decoded_token, params)
      }.not_to change(push_token, :updated_at)
    end

    it 'does not update the user' do
      expect {
        described_class.call(decoded_token, params)
      }.not_to change(user, :updated_at)
    end
  end

  context 'when the user does not exist' do
    let(:decoded_token) { { user_id: user.id + 1 } }

    it 'raises an error' do
      expect {
        described_class.call(decoded_token, params)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end