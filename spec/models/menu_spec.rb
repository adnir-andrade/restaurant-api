# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Menu, type: :model do
  context 'when attributes are valid' do
    subject { build(:menu) }

    it { is_expected.to be_valid }

    context 'when description is empty' do
      subject { build(:menu, description: nil) }

      it { is_expected.to be_valid }
    end

    context 'when attributes are invalid' do
      context 'when name is empty' do
        subject { build(:menu, name: '') }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
