# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  context 'when attributes are valid' do
    subject { build(:menu_item) }

    it { is_expected.to be_valid }

    context 'when menu is not associated' do
      subject { build(:menu_item) }

      it { is_expected.to be_valid }
    end
  end

  context 'when attributes are invalid' do
    context 'when name is not present' do
      subject { build(:menu_item, name: '') }

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
