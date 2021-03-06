class Calendar < ActiveRecord::Base
  serialize :metadata, Oj
  has_many :articles

  def url
    case service
    when "adventar"
      "http://www.adventar.org/calendars/#{in_service_id}"
    when "qiita"
      "http://qiita.com/advent-calendar/#{year}/#{in_service_id}"
    end
  end
end

class Writer < ActiveRecord::Base
  serialize :metadata, Oj
  has_many :articles

  def url
    case service
    when "adventar"
      "http://www.adventar.org/users/#{in_service_id}"
    when "qiita"
      "http://qiita.com/#{in_service_id}"
    end
  end
end

class Article < ActiveRecord::Base
  serialize :metadata, Oj
  belongs_to :calendar
  belongs_to :writer
end
