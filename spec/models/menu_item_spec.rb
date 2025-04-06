# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  context 'when attributes are valid' do
    subject { build(:menu_item) }

    it { is_expected.to be_valid }
  end

  context 'when attributes are invalid' do
    context 'when name is not present' do
      subject { build(:menu_item, name: '') }

      it { is_expected.not_to be_valid }
    end

    context 'when name is not unique' do
      subject { build(:menu_item, name: 'Coffee') }

      before { create(:menu_item, name: 'Coffee') }

      it { is_expected.not_to be_valid }
    end

    context 'when name is not unique (case insensitive)' do
      subject { build(:menu_item, name: 'CoFfEe') }

      before { create(:menu_item, name: 'coffee') }

      it { is_expected.not_to be_valid }
    end

    context 'when price is not present' do
      subject { build(:menu_item, price: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'when price is negative' do
      subject { build(:menu_item, price: -1) }

      it { is_expected.not_to be_valid }
    end
  end
end
