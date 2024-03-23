require 'rails_helper'

RSpec.describe InsulinApplications::GetFilters, type: :service do
  let!(:user) { create(:user) }
  let!(:decoded_token) { { user_id: user.id } }
  let!(:pet) { create(:pet) }
  let!(:params) { { pet_id: pet.id } }
  let!(:insulin_application) { create(:insulin_application, pet_id: pet.id) }
  let!(:insulin_application2) { create(:insulin_application, pet_id: pet.id) }

  before do
    create(:pet_owner, owner_id: user.id, pet_id: pet.id, ownership_level: 'OWNER')
  end

  subject { described_class.call(decoded_token, params).result }

  context 'when insulin application exists' do
    it 'returns the filters' do
      expect(subject).to eq(
        min_date: insulin_application.application_time,
        max_date: insulin_application2.application_time,
        min_units: insulin_application.insulin_units,
        max_units: insulin_application2.insulin_units,
        min_glucose: insulin_application.glucose_level,
        max_glucose: insulin_application2.glucose_level
      )
    end

    it 'does not raise an error' do
      expect do
        subject
      end.to_not raise_error
    end

    context 'when the pet has only 1 insulin application' do
      before do
        insulin_application2.destroy
      end

      it 'returns the filters' do
        expect(subject).to eq(
          min_date: insulin_application.application_time,
          max_date: insulin_application.application_time,
          min_units: insulin_application.insulin_units,
          max_units: insulin_application.insulin_units,
          min_glucose: insulin_application.glucose_level,
          max_glucose: insulin_application.glucose_level
        )
      end
    end

    context 'when the pet does not have glucose values' do
      before do
        InsulinApplication.update_all(glucose_level: nil)
      end

      it 'returns the filters' do
        expect(subject).to eq(
          min_date: insulin_application.application_time,
          max_date: insulin_application2.application_time,
          min_units: insulin_application.insulin_units,
          max_units: insulin_application2.insulin_units,
          min_glucose: nil,
          max_glucose: nil
        )
      end
    end

    context 'when the pet does not have insulin applications' do
      before do
        InsulinApplication.destroy_all
      end

      it 'raises an error' do
        expect do
          subject
        end.to raise_error(Exceptions::NotFoundError, 'Insulin application not found')
      end
    end

    context 'when other pets have insulin applications' do
      before do
        create(:insulin_application,
               pet_id: create(:pet).id,
               application_time: insulin_application.application_time - 1.day,
               insulin_units: insulin_application.insulin_units - 1,
               glucose_level: insulin_application.glucose_level - 1)

        create(:insulin_application,
               pet_id: create(:pet).id,
               application_time: insulin_application2.application_time + 1.day,
               insulin_units: insulin_application2.insulin_units + 1,
               glucose_level: insulin_application2.glucose_level + 1)
      end

      it 'returns the filters' do
        expect(subject).to eq(
          min_date: insulin_application.application_time,
          max_date: insulin_application2.application_time,
          min_units: insulin_application.insulin_units,
          max_units: insulin_application2.insulin_units,
          min_glucose: insulin_application.glucose_level,
          max_glucose: insulin_application2.glucose_level
        )
      end
    end
  end

  context 'when insulin application does not exist' do
    before do
      InsulinApplication.destroy_all
    end

    it 'raises an error' do
      expect do
        subject
      end.to raise_error(Exceptions::NotFoundError, 'Insulin application not found')
    end
  end

  context 'when the pet does not exist' do
    before do
      pet.destroy
    end

    it 'raises an error' do
      expect do
        subject
      end.to raise_error(Exceptions::NotFoundError, 'Not found')
    end
  end

  context 'when the user does not have permission' do
    before do
      PetOwner.destroy_all
    end

    it 'raises an error' do
      expect do
        subject
      end.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  context 'when the user does not have owner permission' do
    before do
      PetOwner.first.update(ownership_level: 'CARETAKER')
    end

    it 'allows anyway' do
      expect do
        subject
      end.to_not raise_error
    end
  end
end