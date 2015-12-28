# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { FactoryGirl.build :location }
  subject { location }

  it { should respond_to(:name) }
  it { should respond_to(:address) }

  it { should have_many :nodes }
end
