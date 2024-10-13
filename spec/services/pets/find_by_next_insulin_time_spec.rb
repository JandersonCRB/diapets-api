require 'rails_helper'

RSpec.describe Pets::FindByNextInsulinTime, type: :service do
  let!(:params) {
    {
      minutes_until_next_insulin: 30,
      excluded_pets: [],
      find_late_pets: true
    }
  }

  context 'when there are many pets' do
    let!(:pet1) { create(:pet, insulin_frequency: 2) }
    let!(:pet2) { create(:pet, insulin_frequency: 2) }
    let!(:pet3) { create(:pet, insulin_frequency: 2) }
    let!(:insulin_application1) { create(:insulin_application, pet: pet1, application_time: 1.hour.ago.utc - 35.minutes) }
    let!(:insulin_application2) { create(:insulin_application, pet: pet2, application_time: 1.hour.ago.utc - 35.minutes) }
    let!(:insulin_application3) { create(:insulin_application, pet: pet3, application_time: 1.hour.ago.utc) }

    it 'returns the pets that need insulin within the next 30 minutes' do
      result = described_class.call(params).result
      expect(result).to eq([pet1, pet2])
    end

    context 'when there are excluded pets' do
      before do
        params[:excluded_pets] = [pet1.id]
      end

      it 'returns the pets that need insulin within the next 30 minutes, excluding the excluded pets' do
        params[:excluded_pets] = [pet1.id]
        result = described_class.call(params).result
        expect(result).to eq([pet2])
      end
    end

    context 'when find_late_pets is false' do
      before do
        params[:find_late_pets] = false
        insulin_application1.update(application_time: 23.hour.ago.utc)
      end

      it 'returns the pets that need insulin within the next 30 minutes' do
        result = described_class.call(params).result
        expect(result).to eq([pet2])
      end
    end

    context 'when there are no pets that need insulin within the next 30 minutes' do
      before do
        insulin_application1.update(application_time: 1.hour.ago.utc - 29.minutes)
        insulin_application2.update(application_time: 1.hour.ago.utc - 29.minutes)
      end

      it 'returns an empty array' do
        result = described_class.call(params).result
        expect(result).to eq([])
      end
    end

    context 'when there are no pets' do
      before do
        InsulinApplication.destroy_all
        Pet.destroy_all
      end

      it 'returns an empty array' do
        result = described_class.call(params).result
        expect(result).to eq([])
      end
    end

    context 'when there are no insulin applications' do
      before do
        insulin_application1.destroy
        insulin_application2.destroy
        insulin_application3.destroy
      end

      it 'returns an empty array' do
        result = described_class.call(params).result
        expect(result).to eq([])
      end
    end

    context 'when there are no pets that need insulin within the next 30 minutes' do
      before do
        insulin_application1.update(application_time: 1.hour.ago.utc - 29.minutes)
        insulin_application2.update(application_time: 1.hour.ago.utc - 29.minutes)
      end

      it 'returns an empty array' do
        result = described_class.call(params).result
        expect(result).to eq([])
      end
    end

    context 'there are pets that notifications were already sent' do
      before do
        SentNotification.create(pet_id: pet1.id, minutes_alarm: 30, last_insulin_id: insulin_application1.id)
      end

      it 'returns the pets that need insulin within the next 30 minutes' do
        result = described_class.call(params).result
        expect(result).to eq([pet2])
      end
    end

    # context 'when there are 999 pets on the database' do
    #   before do
    #     params[:find_late_pets] = false
    #     mock_user = create(:user)
    #     pets = build_list(:pet, 999, insulin_frequency: 2)
    #     pets_to_add = []
    #     last_id = Pet.maximum(:id) || 0
    #     pets.each do |pet|
    #       last_id += 1
    #       pet.id = last_id
    #       pets_to_add << pet.attributes
    #     end
    #     Pet.insert_all(pets_to_add)
    #
    #     last_id = InsulinApplication.maximum(:id) || 0
    #     insulins_to_add = []
    #     pets.each do |pet|
    #       pet_insulin_applications = build_list(:insulin_application, 50, pet_id: pet.id, application_time: 3.hour.ago.utc, user: mock_user, created_at: Time.now.utc, updated_at: Time.now.utc)
    #       pet_insulin_applications << build(:insulin_application, pet_id: pet.id, application_time: 1.hour.ago.utc - 35.minutes, user: mock_user, created_at: Time.now.utc, updated_at: Time.now.utc)
    #
    #       pet_insulin_applications.each do |insulin_application|
    #         last_id += 1
    #         insulin_application.id = last_id
    #       end
    #       insulins_to_add += pet_insulin_applications.map(&:attributes)
    #     end
    #     InsulinApplication.insert_all(insulins_to_add)
    #     InsulinApplication.connection.execute("ALTER SEQUENCE insulin_applications_id_seq RESTART WITH #{last_id + 1}")
    #   end
    #
    #   it 'returns the pets that need insulin within the next 30 minutes' do
    #     result = described_class.call(params).result
    #
    #     expect(result.to_a.size).to eq(1001)
    #   end
    # end
  end
end