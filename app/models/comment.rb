class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :port

  validates :body, presence: true, length: { minimum: 3, maximum: 140 }
end
