class Port < ActiveRecord::Base
  belongs_to :node
  belongs_to :customer
end
