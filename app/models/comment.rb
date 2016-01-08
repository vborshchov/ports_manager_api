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

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :port

  validates :body, presence: true, length: { minimum: 3, maximum: 140 }

  def name
    self.try(:body).to_s
  end
end
