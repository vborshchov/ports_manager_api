require 'rails_helper'

RSpec.describe Node, type: :model do
  let(:node) { FactoryGirl.build :node }
  subject { node }

  it { should respond_to(:name) }
  it { should respond_to(:ip) }
  it { should respond_to(:type) }

  it { should have_many(:ports) }
  it { should belong_to :location }
end
