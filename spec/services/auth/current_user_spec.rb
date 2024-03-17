require 'rails_helper'

RSpec.describe Auth::CurrentUser, type: :service do
  let!(:user) { create(:user) }
  let(:decoded_token) { { user_id: user.id } }

  context 'when user is found' do
    it 'returns a user' do
      result = described_class.call(decoded_token, {}).result
      expect(result).to eq(user)
    end
  end

  context 'when user is not found' do
    it 'returns an error' do
      decoded_token[:user_id] = 0
      expect do
        described_class.call(decoded_token, {})
      end.to raise_error(Exceptions::NotFoundError)
    end
  end
end