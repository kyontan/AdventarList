#!/usr/bin/env ruby
# Coding: UTF-8

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

  def supported_service
    Calendar.select(:service).uniq.map(&:service)
  end
end

get "/?" do
  @date = Date.today
  @articles = Article.where(date: @date).order(:updated_at).reverse

  haml :index
end

get %r{^/(12/\d{1,2})/?$} do
  date = parse_date(params[:captures].first)

  pass if date.nil?

  redirect to("/#{get_year}/#{date.month}/#{date.day}")
end


get %r{^/((?:20)?\d{2}/12/\d{1,2})/?$} do
  @date = parse_date(params[:captures].first)

  pass if @date.nil?

  @articles = Article.where(date: @date).order(:updated_at).reverse

  haml :index
end

get "/calendar/:service/:in_service_id/?" do
  pass unless supported_service.include?(params[:service])

  @service       = params[:service]
  @in_service_id = params[:in_service_id]

  @calendar = Calendar.find_by(service: @service, in_service_id: @in_service_id)
  @articles = @calendar.articles.order(:date)

  haml :index
end

get "/writer/:service/:in_service_id/?" do
  pass unless supported_service.include?(params[:service])

  @service       = params[:service]
  @in_service_id = params[:in_service_id]

  @writer = Writer.find_by(service: @service, in_service_id: @in_service_id)
  @articles = @writer.articles.order(:date)

  haml :index
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
