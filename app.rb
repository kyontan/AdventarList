#!/usr/bin/env ruby
# Coding: UTF-8

require "json"
require_relative "db/model"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = settings.root
end

configure do
  Time.zone = "Tokyo"
  ActiveRecord::Base.default_timezone = :local

  log_path = Pathname(settings.root) + "log"
  FileUtils.makedirs(log_path)
  logger = Logger.new("#{log_path}/#{settings.environment}.log", "daily")
  logger.instance_eval { alias :write :<< unless respond_to?(:write) }
  use Rack::CommonLogger, logger

  # use Rack::Session::Cookie,
  #   key: 'noans.session',
  #   secret: 'fueefuee',
  #   # domain: '',
  #   path: '/',
  #   expire_after: 60 * 60 * 24 * 180 # 3 months

  # use Rack::Protection::RemoteToken
  # use Rack::Protection::SessionHijacking
  # use Rack::Csrf, raise: true

  enable :prefixed_redirects
  set :haml, attr_wrapper: ?"
  set :haml, format: :html5
  set :haml, cdata: false
  set :scss, style: :expanded
  # set :markdown, filter_html: true
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  # 12月以外は前の年を返す
  def get_year
    today = Date.today
    if today.month == 12
      today.year
    else
      today.year - 1
    end
  end

  def parse_date(date_str)
    begin
      date = Date.parse(date_str)
    rescue ArgumentError
      return nil
    end

    return nil if 25 < date.day

    date
  end

  def is_supported_service?
    Calendar.select(:service).uniq.map(&:service)
  end

  def is_supported_format?(format)
    [nil, "json"].include? format
  end

  def articles_as_json(articles, except_writer: false, except_calendar: false)
    opts = {
      include: {
        writer:   { only: [:name,  :in_service_id, :service] },
        calendar: { only: [:title, :in_service_id, :service] }
      },
      except: [
        :created_at, :updated_at, :calendar_id, :writer_id
      ]
    }

    opts[:include].delete(:writer)   if except_writer
    opts[:include].delete(:calendar) if except_calendar

    { articles: articles.as_json(opts) }
  end

  def writer_as_json(writer)
    { writer: writer.as_json(only: [:name,  :in_service_id, :service]) }
  end
  def calendar_as_json(calendar)
    { calendar: calendar.as_json(only: [:title, :in_service_id, :service]) }
  end

end

get %r{^/(12/\d{1,2})\.?(json)?$} do
  date = parse_date(params[:captures].first)
  format = params[:captures].last
  halt 404 if not is_supported_format?(format)

  pass if date.nil?

  redirect to("/#{get_year}/#{date.month}/#{date.day}")
end


get %r{^/((?:20)?\d{2}/12/\d{1,2}).json$} do
  @date = parse_date(params[:captures].first)

  pass if @date.nil?

  @articles = Article.where(date: @date).includes(:calendar, :writer).order(:updated_at).reverse

  content_type :json
  articles_as_json(@articles).to_json
end

get "/calendar/:service/:in_service_id.json" do
  pass unless is_supported_service?.include?(params[:service])

  @service       = params[:service]
  @in_service_id = params[:in_service_id]

  @calendar = Calendar.find_by(service: @service, in_service_id: @in_service_id)
  halt 404 if @calendar.nil?
  @articles = @calendar.articles.includes(:writer).order(:date)

  content_type :json
  articles_as_json(@articles, except_calendar: true).merge(calendar_as_json(@calendar)).to_json

end

get "/writer/:service/:in_service_id.json" do
  pass unless is_supported_service?.include?(params[:service])

  @service       = params[:service]
  @in_service_id = params[:in_service_id]

  @writer = Writer.find_by(service: @service, in_service_id: @in_service_id)
  halt 404 if @writer.nil?
  @articles = @writer.articles.includes(:calendar).order(:date)

  content_type :json
  articles_as_json(@articles, except_writer: true).merge(writer_as_json(@writer)).to_json
end

get "/css/*" do
  file_name = params[:splat].first
  views =  Pathname(settings.views)

  if File.exists?(views + "css" + "#{file_name}")
    send_file views + "css" + "#{file_name}"
  else
    halt 404
  end
end

get "/js/*.js" do
  file_name = params[:splat].first
  views =  Pathname(settings.views)

  if File.exists?(views + "js" + "#{file_name}.js")
    send_file views + "js" + "#{file_name}.js"
  else
    halt 404
  end
end

get "/*" do
  send_file Pathname(settings.public_dir) + "index.html"
end

not_found do
  "not_found"
end
