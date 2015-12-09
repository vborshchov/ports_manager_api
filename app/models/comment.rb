class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :port

  validates_presence_of :body
end
