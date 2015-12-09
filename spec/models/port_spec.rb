# == Schema Information
#
# Table name: ports
#
#  id          :integer          not null, primary key
#  name        :string
#  state       :string
#  description :string
#  node_id     :integer
#  customer_id :integer
#  reserved    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

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

  it { should have_many(:comments) }
  # it { should belong_to :node }
  # it { should belong_to :customer }
end
