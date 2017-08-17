require 'rails_helper'

RSpec.describe Author, type: :model do
  it { is_expected.to have_many :follows }
  it { is_expected.to have_many :followers }
  it { is_expected.to have_many :books }
end
