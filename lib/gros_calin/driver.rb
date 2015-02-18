module GrosCalin

  class << self
    def drivers
      @drivers ||= {}
    end
  end

  module Driver
    attr_reader :options

    def initialize(options={})
      @options = options
    end

    def id
      self.class.id
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      attr_reader :id

      def register(id)
        GrosCalin.drivers[@id = id] = self
      end

    end

  end

end

require "gros_calin/mysql"
require "gros_calin/mongo_db"
