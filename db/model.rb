class Calendar < ActiveRecord::Base
	has_many :articles
end

class Writer < ActiveRecord::Base
	has_many :articles
end

class Article < ActiveRecord::Base
	belongs_to :calendar
end
