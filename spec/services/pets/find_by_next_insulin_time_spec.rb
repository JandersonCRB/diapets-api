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
  end
end