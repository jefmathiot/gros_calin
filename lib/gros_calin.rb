require "gros_calin/version"
require "gros_calin/config"
require "gros_calin/driver"
require "sinatra/base"
require "sinatra/json"

module GrosCalin

  class Application < Sinatra::Base
    helpers Sinatra::JSON

    set :show_exceptions, false

    def config
      settings.config
    end

    def datasource(id)
      config.datasources.get(id).tap do |datasource|
        unless datasource
          raise Sinatra::NotFound.new("Unknown datasource with id \"#{id}\"")
        end
      end
    end

    def hug(datasource, id)
      datasource(datasource).hugs.get(id).tap do |hug|
        unless hug
          raise Sinatra::NotFound.new("Unknown hug with identifier \"#{id}\" " +
            "for datasource \"#{datasource}\"")
        end
      end
    end

    not_found do
      env['sinatra.error'].message
    end

    error do
      'Something went wrong: ' + env['sinatra.error'].message
    end

    # List the available datasources
    get '/' do
      json config.datasources.json
    end

    # Show the details and available hugs for a given datasource
    get '/:datasource' do
      json datasource(params[:datasource]).hugs.map(&:json)
    end


    # Query a specific hug
    get '/:datasource/:hug' do
      json hug(params[:datasource], params[:hug]).results
    end

  end

end
