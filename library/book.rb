load 'base.rb'

class Book < Base
  attribute :user_id, Integer	
  attribute :title, String
  attribute :author, String

  belongs_to :user
end
