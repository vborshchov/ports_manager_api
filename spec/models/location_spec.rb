require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { FactoryGirl.build :location }
  subject { location }

  it { should respond_to(:name) }
  it { should respond_to(:address) }

  it { should have_many :nodes }
end
