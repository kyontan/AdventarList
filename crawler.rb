#!/usr/bin/env ruby

require "bundler"

Bundler.require
Bundler.require(settings.environment)

require "./app"

disable :run

require "open-uri"
require "nokogiri"
require "json"

ActiveRecord::Base.logger.level = Logger::WARN

class Hash
  def slice(*keys)
    Hash[keys.map{|k| [k, self[k]] }]
  end
end

def parse_document(url)
  charset = nil

  begin
    options = {}
    html = OpenURI.open_uri(url, options) do |f|
      charset = f.charset
      f.read
    end

    return Nokogiri::HTML.parse(html, nil, charset)
  rescue => e
    puts e.to_s
    return nil
  end
end

def create_or_update(klass, attrs)
  keys = \
       if klass == Calendar then attrs.slice(:in_service_id, :service)
    elsif klass == Writer   then attrs.slice(:in_service_id, :service)
    elsif klass == Article  then attrs.slice(:date, :calendar)
  end

  instance = klass.find_or_create_by(keys)
  instance.attributes = attrs

  ret = instance.changed?

  instance.save

  ret
end

def update_adventar
  def update_calendars
    root = "http://www.adventar.org/"
    doc = parse_document(root)

    props = JSON.parse(doc.css("div[data-react-class=CalendarList]").attribute("data-react-props"))
    calendars = props.first.last

    calendars.each do |p|
      id, title = p["id"], p["title"]
      if create_or_update(Calendar, {
          in_service_id: id,
          title: title,
          service: "adventar"
        })
        puts "Calendar##{id} title: #{title}"
      end
    end
  end

  update_calendars

  Calendar.all.each do |cal|
    doc = parse_document(cal.url)
    next if doc.nil?

    doc.css("table.mod-entryList tr").each do |article_tree|
      user_name = article_tree.css(".mod-entryList-user a").text
      user_id   = article_tree.css(".mod-entryList-user a")[:href].match(/\d+$/)[0]

      date  = Date.parse(article_tree.css(".mod-entryList-date").text)
      title = article_tree.css(".mod-entryList-title").text
      desc  = article_tree.css(".mod-entryList-comment").text
      url   = article_tree.css(".mod-entryList-url a").attr("href")

      if url.nil? || url.value.empty?
        next
      else
        url = url.value
      end

      # Writer

      if create_or_update(Writer, {
          in_service_id: user_id,
          name: user_name,
          service: "adventar"
          })
        puts "Writer##{user_id} name: #{user_name}"
      end

      # Article

      if create_or_update(Article, {
          title: title,
          description: desc,
          url: url,
          date: date,
          calendar: cal,
          writer: Writer.find_by(in_service_id: user_id, service: "adventar")
        })

        puts "Article: Calendar##{cal.in_service_id}, title: #{title}"
      end
    end
  end
end

update_adventar

# def update_qiita
# end