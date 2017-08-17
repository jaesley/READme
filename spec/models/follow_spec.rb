require 'rails_helper'

RSpec.describe Follow, type: :model do
  it { is_expected.to belong_to :author }
  it { is_expected.to belong_to :user }
end
