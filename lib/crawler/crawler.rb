require "logger"
require "open-uri"
require "nokogiri"
require "json"

class Crawler
  private def initialize(store:, logger: nil)
    @store = store
    @logger = logger
  end

  def service_name; end

  def crawl_all(year: Date.today.year, in_service_id: nil)
    crawl_only_calendars(year: year)

    attrs = {
      year: year,
      in_service_id: in_service_id
    }.delete_if{|k, v| v.nil? }

    calendars = get_calendars(attrs)
    calendars.each do |cal|
      page = parse_page(url: cal.url, raises: false)
      next if page.nil?
      parse_calendar_page(doc: page, cal: cal)
    end
  end

  def crawl_only_calendars(year: Date.today.year)
    url = url_of_calendar_list(year: year)
    page = parse_page(url: url, raises: false)
    return if page.nil?

    parse_calendar_list_page(doc: page, year: year)
  end

  private

  def base_url; end

  def url_of_calendar_list(year: ); end

  def service_identifier; end

  def parse_calendar_list_page(doc:, year:); end

  def parse_calendar_page(doc:, cal:); end

  def save_calendar(attrs)
    @store.save_calendar(with_service_id(attrs))
  end

  def get_calendars(attrs)
    @store.get_calendars(with_service_id(attrs))
  end

  def save_writer(attrs)
    @store.save_writer(with_service_id(attrs))
  end

  def get_writer(attrs)
    @store.get_writer(with_service_id(attrs))
  end

  def save_article(attrs)
    @store.save_article(attrs)
  end

  def with_service_id(attrs)
    attrs.merge({ service: service_identifier })
  end

  def parse_page(url:, raises: true)
    charset = nil

    begin
      options = {}
      html = OpenURI.open_uri(url, options) do |f|
        charset = f.charset
        f.read
      end

      page = Nokogiri::HTML.parse(html, nil, charset)

      return page if not page.nil?

      message = "Can't parse page: #{url}"
      if raises
        raise message
      else
        @logger&.error message
      end

      return nil
    rescue => e
      @logger&.error e.to_s
      return nil
    end
  end
end
