# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  context 'when attributes are valid' do
    subject { build(:restaurant) }

    it { is_expected.to be_valid }

    context 'when name is empty' do
      subject { build(:restaurant, name: '') }

      it { is_expected.not_to be_valid }
    end

    context 'when restaurant has menus' do
      subject { restaurant.menus }

      let!(:restaurant) { create(:restaurant, menus: [create(:menu)]) }

      it { is_expected.not_to be_empty }
    end
  end

  context 'when attributes are invalid' do
    context 'when name is empty' do
      subject { build(:restaurant, name: '') }

      it { is_expected.not_to be_valid }
    end
  end
end
