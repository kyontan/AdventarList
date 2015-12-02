require "logger"
require "bundler"

require 'fileutils'
FileUtils.makedirs(["log"])

Bundler.require

set :environment, :development
# set :environment, :production

Bundler.require(settings.environment)

Dotenv.load

require File.expand_path(File.dirname(__FILE__)) + '/app.rb'

run Sinatra::Application
