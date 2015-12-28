# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  account    :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:customer) { FactoryGirl.build :customer }
  subject { customer }

  it { should respond_to(:account) }
  it { should respond_to(:name) }

  it { should have_many :ports }
end
