require 'rails_helper'

RSpec.describe Book, type: :model do
  it { is_expected.to belong_to :author }
  it { is_expected.to have_many :follows }
  it { is_expected.to have_many :followers }
end
