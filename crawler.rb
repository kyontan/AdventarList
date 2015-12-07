#!/usr/bin/env ruby

require "bundler"

Bundler.require
Bundler.require(settings.environment)

require "./app"

disable :run

require "open-uri"
require "nokogiri"
require "json"

def parse_document(url)
  charset = nil

  begin
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    return Nokogiri::HTML.parse(html, nil, charset)
  rescue
    return nil
  end
end

def update_adventar
  def update_calendars
    root = "http://www.adventar.org/"
    doc = parse_document(root)

    props = JSON.parse(doc.css("div[data-react-class=CalendarList]").attribute("data-react-props"))
    calendars = props.first.last

    calendars.each do |p|
      id, title = p["id"], p["title"]
      calendar = Calendar.find_or_create_by(in_service_id: id, service: "adventar")
      attrs = {
        in_service_id: id,
        title: title,
        service: "adventar"
      }
      calendar.attributes = attrs
      puts "calendar id: #{id}, title: #{title}" if calendar.changed?
    end
  end

  update_calendars

  Calendar.all.each do |cal|
    doc = parse_document(cal.url)
    next if doc.nil?

    doc.css("table.mod-entryList tr").each do |article_tree|
      user_name = article_tree.css(".mod-entryList-user a").text
      user_id   = article_tree.css(".mod-entryList-user a").attr("href").value.match(/\d+$/)[0]

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

      writer = Writer.find_or_create_by(in_service_id: user_id, service: "adventar")
      attrs = {
        name: user_name,
        in_service_id: user_id,
        service: "adventar"
      }
      writer.attributes = attrs
      puts "user: #{user_name}, id: #{user_id}" if writer.changed?

      writer = Writer.where(in_service_id: user_id, service: "adventar").first

      # Article
      article = Article.find_or_create_by(date: date, calendar: cal)
      attrs = {
        title: title,
        description: desc,
        url: url,
        date: date,
        calendar: cal,
        writer: writer
      }
      article.attributes = attrs

      puts "article: Calendar##{cal.in_service_id}, title: #{title}" if article.changed?
      article.save
    end
  end
end

update_adventar

# def update_qiita
# end