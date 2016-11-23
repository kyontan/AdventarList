require "date"
require "nokogiri"
require_relative "crawler"

class Crawler::Qiita < Crawler
  def initialize(**attrs)
    super(attrs)
  end

  def service_name
    "Qiita"
  end

  private

  def base_url
    URI("http://qiita.com/advent-calendar/")
  end

  def service_identifier
    "qiita"
  end

  def parse_calendar_list_page(doc:, year:)
    def parse_list(doc, year)
      doc.css(".adventCalendarList_calendarTitle").each do |cal_el|
        title_el = cal_el.css("a")
        id = title_el.attr("href").value.split("/").last.strip

        changed = save_calendar(
          title: strip(title_el.text.strip),
          in_service_id: id,
          year: year,
        )

        @logger&.info "#{service_name}: updated calendar #{id}" if changed
      end
    end

    if year < 2015
      # Category page is not exist for calendar before than 2015
      parse_list(doc, year)
    else
      category_page_urls = doc.css("a.adventCalendarCard_block_showAll").map do |x|
        base_url + x.attr("href")
      end

      category_page_urls.each do |cat_url|
        cat_doc = parse_page(url: cat_url, raises: false)
        parse_list(cat_doc, year)
      end
    end
  end

  def parse_calendar_page(doc:, cal:)
    entries_doc = doc.css(".adventCalendarCalendar_day")

    @logger&.debug "#{service_name}: Crawling: #{cal.url}, #{entries_doc.count} entries."

    entries_doc.each do |entry_doc|
      # if no entry
      next if not entry_doc.css(".adventCalendarCalendar_join").empty?

      day = entry_doc.css(".adventCalendarCalendar_date").text.to_i
      date = Date.new(cal.year, 12, day)

      user_id   = strip(entry_doc.css(".adventCalendarCalendar_author a").text)

      # NOTE: Qiita user has name attribute, but getting it needs parsing user's page
      user_name = user_id

      title_el = entry_doc.css(".adventCalendarCalendar_comment a")
      # if no entry
      next if title_el.nil? || title_el.empty?

      title = strip(title_el.text)
      desc  = ""
      url   = title_el.attr("href").text

      # if no entry url
      next if url.nil? || url.empty?

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
    base_url + "#{year}/"
  end

  # def url_of_calendar(year:, name: )
  #   base_url + "#{year}/#{name}/"
  # end
end
