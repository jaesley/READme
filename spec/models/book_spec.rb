require 'rails_helper'

RSpec.describe Book, type: :model do
  context '#associations' do
    it { is_expected.to belong_to :author }
    it { is_expected.to have_many :follows }
    it { is_expected.to have_many :followers }
  end

  context '#validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :goodreads_id }
    it { is_expected.to validate_presence_of :publication_date }

    it { is_expected.to validate_uniqueness_of :goodreads_id }
  end
end
