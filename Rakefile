require "bundler"

Bundler.require
Bundler.require(settings.environment)

require "sinatra/activerecord/rake"

namespace :db do
  desc <<-EOS
    Loads seed data for the current environment. It will look for
    ruby seed files in (settings.root)/db/fixtures/ and
    (settings.root)/db/fixtures/(settings.environment)/.

    By default it will load any ruby files found. You can filter the files
    loaded by passing in the FILTER environment variable with a comma-delimited
    list of patterns to include. Any files not matching the pattern will
    not be loaded.

    You can also change the directory where seed files are looked for
    with the FIXTURE_PATH environment variable.

    Examples:
      # default, to load all seed files for the current environment
      rake db:seed_fu

      # to load seed files matching orders or customers
      rake db:seed_fu FILTER=orders,customers

      # to load files from settings.root/features/fixtures
      rake db:seed_fu FIXTURE_PATH=features/fixtures
  EOS
  task :seed_fu => :environment do

    if ENV["FILTER"]
      filter = /#{ENV["FILTER"].gsub(/,/, "|")}/
    end

    if ENV["FIXTURE_PATH"]
      fixture_paths = [ENV["FIXTURE_PATH"], ENV["FIXTURE_PATH"] + "/" + settings.environment.to_s]
    end

    SeedFu.seed(fixture_paths, filter)
  end

  task :load_config do
    require "./app"
  end
end

Rake::Task["db:seed_fu"].enhance(["db:load_config"])

SeedFu.fixture_paths = [
  Pathname(settings.root).join("db/fixtures").to_s,
  Pathname(settings.root).join("db/fixtures/#{settings.environment}").to_s
]
