module GrosCalin

  begin

    require 'moped'

    class MongoDB
      include Driver
      register 'mongodb'

      ALLOWED_METHODS=[
        'find',
        'count',
        'aggregate',
        'limit',
        'skip',
        'sort',
        'distinct',
        'select',
        'first',
        'one'
      ].freeze

      def query(id, spec)
        collection = mandatory(spec, 'collection')
        query = mandatory(spec, 'query')
        with_session do |session|
          results = session[collection]
          whitelist(query).each do |method_descriptor|
            if method_descriptor.is_a?(Hash)
              method = method_descriptor.keys.first
              args = method_descriptor[method]
              results = results.send(method, args)
            else
              results = results.send(method_descriptor)
            end
          end
          if results.is_a?(Hash)
            results
          elsif results.respond_to?(:to_a)
            results.to_a
          else
            { id => results }
          end
        end
      end

      protected

      def with_session(&block)
        session = Moped::Session.new(@options['hosts'] || ['127.0.0.1:27017'])
        session.use @options['database']
        if @options['username']
          session.login(@options['username'], @options['password'])
        end
        yield session
      end

      def mandatory(options, attr)
        raise "\"#{attr}\" has not been specified" unless options[attr]
        options[attr]
      end

      def whitelist(query)
        query.select{|descriptor|
          name = descriptor.is_a?(Hash) && descriptor.keys.first || descriptor
          ALLOWED_METHODS.include?(name)
        }
      end

    end

  rescue
    puts "Unable to find the moped gem, driver for MongoDB won't load."
  end

end
