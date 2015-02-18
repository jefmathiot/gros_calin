require 'gros_calin'

GrosCalin::Application.set :config,
  GrosCalin::Config.new(ENV['GROS_CALIN_CONFIG'])
run GrosCalin::Application
