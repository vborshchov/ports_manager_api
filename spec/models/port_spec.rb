require 'rails_helper'

RSpec.describe Port, type: :model do
  let(:port) { FactoryGirl.build :port }
  subject { port }

  it { should respond_to(:name) }
  it { should respond_to(:state) }
  it { should respond_to(:description) }
  it { should respond_to(:node_id) }
  it { should respond_to(:customer_id) }
  it { should respond_to(:reserved) }
end