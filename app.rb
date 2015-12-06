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
  set :database, {adapter: "sqlite3", database: "db/#{settings.environment}.sqlite3"}
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
end

get "/?" do
  # @date = Date.today
  @date = Date.parse("12/3")
  @articles = Article.where(date: @date).order(:updated_at).reverse

  haml :index
end

# get %r{/\d{4}/\d{4}/\d{4}}

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
