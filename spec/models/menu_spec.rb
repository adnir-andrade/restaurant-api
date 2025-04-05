require 'rails_helper'

RSpec.describe Menu, type: :model do
  context 'when attributes are valid' do
    subject { build(:menu) }

    it { is_expected.to be_valid }

    context 'when description is empty' do
      let(:menu) { build(:menu, description: nil) }

      it 'is valid' do
        expect(menu).to be_valid
      end
    end

    context 'when attributes are invalid' do
      it 'is not valid without a name' do
        expect(build(:menu, name: '')).not_to be_valid
      end
    end
  end
end
