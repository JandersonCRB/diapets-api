require 'rails_helper'

describe Pets::FindAllInsulinApplications, type: :service do
  let!(:user) { create(:user) }
  let!(:decoded_token) { { user_id: user.id } }
  let!(:pet) {
    pet = create(:pet)
    create(:pet_owner, owner: user, pet: pet, ownership_level: 'OWNER')
    pet
  }

  let!(:params) do
    {
      pet_id: pet.id
    }
  end

  context 'when there is one insulin application for the pet' do
    let!(:insulin_application) {
      create(:insulin_application, pet: pet, user: user)
    }
    it 'returns the last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result.to_a).to eq([insulin_application])
    end
  end

  context 'when the user is a caretaker' do
    let!(:insulin_application) {
      create(:insulin_application, pet: pet, user: user)
    }
    before do
      PetOwner.where(owner_id: user.id, pet_id: pet.id).update(ownership_level: 'CARETAKER')
    end
    it 'returns the last insulin application' do
      result = described_class.call(decoded_token, params).result
      expect(result.to_a).to eq([insulin_application])
    end
  end

  context 'when there is no insulin application for the pet' do
    it 'returns an empty array' do
      result = described_class.call(decoded_token, params).result
      expect(result.to_a).to eq([])
    end
  end

  context 'when the pet does not exist' do
    it 'raises a not found error' do
      expect {
        described_class.call(decoded_token, params.merge(pet_id: 0)).result
      }.to raise_error(Exceptions::NotFoundError)
    end
  end

  context 'when the user does not have permission to access the pet' do
    it 'raises an unauthorized error' do
      expect {
        described_class.call(decoded_token, params.merge(pet_id: create(:pet).id)).result
      }.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  context 'when the user is not authenticated' do
    it 'raises an unauthorized error' do
      expect {
        described_class.call({}, params).result
      }.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  context 'when the user is not authorized' do
    it 'raises an unauthorized error' do
      expect {
        described_class.call({ user_id: create(:user).id }, params).result
      }.to raise_error(Exceptions::UnauthorizedError)
    end
  end

  describe 'filters' do
    describe 'application_time' do
      context 'min_date is bigger than the first application and max_date is lesser than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        before do
          params[:min_date] = Date.new(2024, 05, 02)
          params[:max_date] = Date.new(2024, 05, 02)
        end

        it 'returns only the second insulin application' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2])
        end
      end

      context 'min_date is bigger than the first application and max_date is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        before do
          params[:min_date] = Date.new(2024, 05, 02)
        end

        it 'returns the second and third insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2, insulin_application_3])
        end
      end

      context 'min_date is nil and max_date is lesser than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        before do
          params[:max_date] = Date.new(2024, 05, 02)
        end

        it 'returns the first and second insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2])
        end
      end

      context 'min_date is nil and max_date is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end
      end

      context 'min_date is bigger than the last application and max_date is bigger than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        before do
          params[:min_date] = Date.new(2024, 05, 04)
          params[:max_date] = Date.new(2024, 05, 05)
        end

        it 'returns an empty array' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to eq([])
        end
      end

      context 'min_date is lesser than the first application and max_date is lesser than the first application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        before do
          params[:min_date] = Date.new(2024, 04, 30)
          params[:max_date] = Date.new(2024, 04, 30)
        end

        it 'returns an empty array' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to eq([])
        end
      end

      context 'min_date is nil and max_date is bigger than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
        }

        before do
          params[:max_date] = Date.new(2024, 05, 04)
        end

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end

        context 'min_date is equal to max_date' do
          let!(:insulin_application_1) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
          }
          let!(:insulin_application_2) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
          }
          let!(:insulin_application_3) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
          }

          before do
            params[:min_date] = Date.new(2024, 05, 02)
            params[:max_date] = Date.new(2024, 05, 02)
          end

          it 'returns the second insulin application' do
            result = described_class.call(decoded_token, params).result
            expect(result.to_a).to match_array([insulin_application_2])
          end
        end

        context 'min_date is equal one of the applications' do
          let!(:insulin_application_1) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
          }
          let!(:insulin_application_2) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
          }
          let!(:insulin_application_3) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
          }

          before do
            params[:min_date] = Date.new(2024, 05, 02)
            params[:max_date] = Date.new(2024, 05, 04)
          end

          it 'returns the second and third insulin applications' do
            result = described_class.call(decoded_token, params).result
            expect(result.to_a).to match_array([insulin_application_2, insulin_application_3])
          end
        end

        context 'max_date is equal one of the applications' do
          let!(:insulin_application_1) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 01))
          }
          let!(:insulin_application_2) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 02))
          }
          let!(:insulin_application_3) {
            create(:insulin_application, pet: pet, user: user, application_time: DateTime.new(2024, 05, 03))
          }

          before do
            params[:min_date] = Date.new(2024, 05, 01)
            params[:max_date] = Date.new(2024, 05, 02)
          end

          it 'returns the first and second insulin applications' do
            result = described_class.call(decoded_token, params).result
            expect(result.to_a).to match_array([insulin_application_1, insulin_application_2])
          end
        end
      end
    end

    describe 'units' do
      context 'min_units is bigger than the first application and max_units is lesser than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 2
          params[:max_units] = 2
        end

        it 'returns only the second insulin application' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2])
        end
      end

      context 'min_units is bigger than the first application and max_units is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 2
        end

        it 'returns the second and third insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2, insulin_application_3])
        end
      end

      context 'min_units is nil and max_units is lesser than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params
          params[:max_units] = 2
        end

        it 'returns the first and second insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2])
        end
      end

      context 'min_units is nil and max_units is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end
      end

      context 'min_units is bigger than the last application and max_units is bigger than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 4
          params[:max_units] = 5
        end

        it 'returns an empty array' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to eq([])
        end
      end

      context 'min_units is lesser than the first application and max_units is lesser than the first application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 0
          params[:max_units] = 0
        end

        it 'returns an empty array' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to eq([])
        end
      end

      context 'min_units is nil and max_units is bigger than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:max_units] = 4
        end

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end
      end

      context 'min_units is equal to max_units' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 2
          params[:max_units] = 2
        end

        it 'returns the second insulin application' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2])
        end
      end

      context 'min_units is equal one of the applications' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 2
          params[:max_units] = 4
        end

        it 'returns the second and third insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2, insulin_application_3])
        end
      end

      context 'max_units is equal one of the applications' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, insulin_units: 3)
        }

        before do
          params[:min_units] = 1
          params[:max_units] = 2
        end

        it 'returns the first and second insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2])
        end
      end
    end

    describe 'glucose' do
      context 'when min_glucose is bigger than the first application and max_glucose is lesser than the last applications' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 2
          params[:max_glucose] = 2
        end

        it 'returns only the second insulin application' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2])
        end
      end

      context 'when min_glucose is bigger than the first application and max_glucose is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 2
        end

        it 'returns the second and third insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2, insulin_application_3])
        end
      end

      context 'when min_glucose is nil and max_glucose is lesser than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:max_glucose] = 2
        end

        it 'returns the first and second insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2])
        end
      end

      context 'when min_glucose is nil and max_glucose is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end
      end

      context 'when min_glucose is bigger than the last application and max_glucose is bigger than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 4
          params[:max_glucose] = 5
        end

        it 'returns an empty array' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to eq([])
        end
      end

      context 'when min_glucose is lesser than the first application and max_glucose is lesser than the first application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 0
          params[:max_glucose] = 0
        end

        it 'returns an empty array' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to eq([])
        end
      end

      context 'when min_glucose is nil and max_glucose is bigger than the last application' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:max_glucose] = 4
        end

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end
      end

      context 'when min_glucose is equal to max_glucose' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 2
          params[:max_glucose] = 2
        end

        it 'returns the second insulin application' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2])
        end
      end

      context 'when min_glucose is equal one of the applications' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 2
          params[:max_glucose] = 4
        end

        it 'returns the second and third insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_2, insulin_application_3])
        end
      end

      context 'when max_glucose is equal one of the applications' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        before do
          params[:min_glucose] = 1
          params[:max_glucose] = 2
        end

        it 'returns the first and second insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2])
        end
      end

      context 'when min_glucose is nil and max_glucose is nil' do
        let!(:insulin_application_1) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 1)
        }
        let!(:insulin_application_2) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 2)
        }
        let!(:insulin_application_3) {
          create(:insulin_application, pet: pet, user: user, glucose_level: 3)
        }

        it 'returns all insulin applications' do
          result = described_class.call(decoded_token, params).result
          expect(result.to_a).to match_array([insulin_application_1, insulin_application_2, insulin_application_3])
        end
      end
    end
  end
end