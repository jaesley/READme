require 'rails_helper'

RSpec.describe Author, type: :model do
  context '#associations' do
    it { is_expected.to have_many :follows }
    it { is_expected.to have_many :followers }
    it { is_expected.to have_many :books }
  end

  context '#validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :goodreads_id }

    it { is_expected.to validate_uniqueness_of :goodreads_id }
  end
end
