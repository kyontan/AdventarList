require "logger"
require "open-uri"
require "nokogiri"
require "json"

class Crawler
  private
  def initialize(store:)
    raise "Abstruct class can't initialize"
  end

  def base_uri; end

  def service_name; end

  def service_identifier; end

  def crawl_all(year: Date.today.year, calendar: ""); end

  def crawl_calendars(); end

  private

  def save_calendar(attrs)
    self.store.save_calendar(attrs)
  end

  def save_writer(attrs)
    self.store.save_writer(attrs)
  end

  def save_article(attrs)
    self.store.save_article(attrs)
  end

  def parse_page(url:)
    charset = nil

    begin
      options = {}
      html = OpenURI.open_uri(url, options) do |f|
        charset = f.charset
        f.read
      end

      return Nokogiri::HTML.parse(html, nil, charset)
    rescue => e
      $logger.error e.to_s
      return nil
    end
  end
end
