require 'yaml'

module GrosCalin

  class Collection < Array

    def json
      map(&:json)
    end

    def get(id)
      find{ |item| item.respond_to?(:id) && item.id == id }
    end

  end

  module Identifier

    def self.included(base)
      base.send :attr_reader, :id
    end

  end

  class Datasource
    include Identifier

    attr_reader :driver

    def initialize(id, driver, options={})
      @id = id
      @driver = driver.new(options)
    end

    def hugs
      @hugs ||= Collection.new
    end

    def json
      {
        id: id,
        driver: driver.id,
        uri: "/#{id}"
      }
    end

  end

  class Hug
    include Identifier

    attr_reader :datasource, :query

    def initialize(id, datasource, query)
      @id = id
      @datasource = datasource
      @query = query
    end

    def json
      {
        id: id,
        datasource: datasource.json,
        uri: "/#{datasource.id}/#{id}"
      }
    end

    def results
      datasource.driver.query(id, @query)
    end

  end

  class Config

    def initialize(config='./config.yml')
      yaml = load(config)
      raise "Invalid YAML file #{config}" unless yaml
      yaml.each do |id, ds|
        datasource = Datasource.new(id, driver(ds['driver']), ds['options'])
        (ds['hugs'] || []).each do |id, query|
          datasource.hugs << Hug.new( id, datasource, query )
        end
        datasources << datasource
      end
    end

    def datasources
      @datasources ||= Collection.new
    end

    private
    def load(config)
      YAML.load(File.read(File.expand_path(config)))
    end

    def driver(id)
      GrosCalin.drivers[id]
    end

  end

end
