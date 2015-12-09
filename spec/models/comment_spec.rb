require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:comment) { FactoryGirl.build :comment }
  subject { comment }

  it { should respond_to(:body) }
  it { should respond_to(:user_id) }
  it { should respond_to(:port_id) }

end
