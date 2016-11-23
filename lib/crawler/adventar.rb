require "date"
require "nokogiri"
require_relative "crawler"

class Crawler::Adventar < Crawler
  def initialize(**attrs)
    super(attrs)
  end

  def service_name
    "Adventar"
  end

  private

  def base_url
    URI("http://www.adventar.org/")
  end

  def service_identifier
    "adventar"
  end

  def parse_calendar_list_page(doc:, year:)
    doc.css(".mod-calendarList ul li").each do |cal_el|
      title_el = cal_el.css(".mod-calendarList-title")
      id = title_el.css("a").attr("href").value.match(/\d+$/).to_s

      changed = save_calendar(
        title: strip(title_el.text),
        in_service_id: id,
        year: year,
      )

      @logger&.info "#{service_name}: updated calendar #{id}" if changed
    end
  end

  def parse_calendar_page(doc:, cal:)
    selector = "[data-react-class=CalendarContainer]"
    json = doc.css(selector).attribute("data-react-props")
    entries = JSON.parse(json)["entries"]

    @logger&.debug "#{service_name}: Crawling: #{cal.url}, #{entries.count} entries."

    entries.each do |entry|
      user_name = strip(entry["user"]["name"])
      user_id   = entry["user"]["id"]

      url   = entry["url"]

      # if no entry
      next if url.nil? || url.empty?

      date  = Date.parse(entry["date"])
      title = entry["title"].nil?   ? "" : strip(entry["title"])
      desc  = entry["comment"].nil? ? "" : strip(entry["comment"])

      changed = save_writer(
        in_service_id: user_id,
        name: user_name,
      )

      @logger&.info "#{service_name}: updated writer: #{user_name}" if changed

      changed = save_article(
        title: title,
        description: desc,
        url: url,
        date: date,
        calendar: cal,
        writer: get_writer(in_service_id: user_id),
      )

      @logger&.info "#{service_name}: updated article: #{title} (cal##{cal.in_service_id})" if changed
    end
  end

  def url_of_calendar_list(year: )
    base_url + "/calendars?year=#{year}"
  end

  # def url_of_calendar(id: )
  #   base_url + "calendars/#{id}"
  # end
end
