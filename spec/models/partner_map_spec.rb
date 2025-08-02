# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerMap, type: :model do
  describe '.mappable_class' do
    it 'returns Partner' do
      expect(described_class.mappable_class).to eq(Partner)
    end
  end
end
