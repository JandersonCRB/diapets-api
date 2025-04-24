require 'rails_helper'

RSpec.describe PushNotifications::NotifyUsers do
  let(:user) { create(:user) }
  let(:push_token) { create(:push_token, user: user) }
  let(:title) { 'Test Title' }
  let(:body) { 'Test Body' }

  describe '#call' do
    it 'sends a push notification to the user' do
      described_class.new([push_token], title, body).call

      fcm = instance_double(FCM)
      allow(FCM).to receive(:new).and_return(fcm)
      allow(fcm).to receive(:send_v1)
    end
  end
end
