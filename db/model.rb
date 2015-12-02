class Calendar < ActiveRecord::Base
  self.primary_keys = :id, :service

  has_many :articles
end

class Writer < ActiveRecord::Base
  self.primary_keys = :id, :service

  has_many :articles
end

class Article < ActiveRecord::Base
  belongs_to :calendar
end
