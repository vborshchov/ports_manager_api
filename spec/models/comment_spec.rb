# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :string
#  user_id    :integer
#  port_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:comment) { FactoryGirl.build :comment }
  subject { comment }

  it { should respond_to(:body) }
  it { should respond_to(:user_id) }
  it { should respond_to(:port_id) }

  it { should belong_to :user }
  it { should belong_to :port }

end
