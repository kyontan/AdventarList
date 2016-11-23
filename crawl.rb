#!/usr/bin/env ruby
RACK_ENV = ENV.fetch("RACK_ENV", "development")

require "singleton"
require "bundler"
Bundler.require(:default, RACK_ENV)

disable :run # prevent running sinatra applicaton

require_relative "db/model"
require_relative "lib/crawler/qiita"
require_relative "lib/crawler/adventar"

Time.zone = "Asia/Tokyo"
ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.logger.level = Logger::WARN
ActiveRecord::Base.establish_connection(
  adapter:  "sqlite3",
  database: "db/#{RACK_ENV}.sqlite3"
)

logger = Logger.new("log/crawler.log")

class Hash
  def slice(*keys)
    Hash[keys.map{|k| [k, self[k]] }]
  end
end

class CrawlerStore
  include Singleton

  def save_calendar(attrs)
    keys = attrs.slice(:in_service_id, :service, :year)
    create_or_update(Calendar, keys, attrs)
  end

  def get_calendars(attrs)
    Calendar.where(attrs)
  end

  def save_writer(attrs)
    keys = attrs.slice(:in_service_id, :service)
    create_or_update(Writer, keys, attrs)
  end

  def get_writer(attrs)
    Writer.find_by(attrs)
  end

  def save_article(attrs)
    keys = attrs.slice(:date, :calendar)
    create_or_update(Article, keys, attrs)
  end

  private
  def create_or_update(klass, keys, attrs)
    instance = klass.find_or_create_by(keys)
    instance.attributes = attrs

    changed = instance.changed?
    instance.save

    changed
  end
end

crawlers = [
  Crawler::Qiita,
  Crawler::Adventar,
].map do |c|
  c.new(store: CrawlerStore.instance, logger: logger)
end

today = Date.today
year = today.month == 12 ? today.year : (today.year - 1)

crawlers.each do |crawler|
  logger.info "Crawler start for #{crawler.service_name}: #{Time.now}"
  begin
    crawler.crawl_all(year: year)
  rescue => e
    $logger.error e.to_s
  end
  $logger.info "Crawler finished for #{crawler.service_name}: #{Time.now}"
end
