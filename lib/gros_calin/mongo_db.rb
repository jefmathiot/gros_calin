module GrosCalin

  begin

    require 'moped'

    class MongoDB
      include Driver

      register 'mongodb'

      def query(id, js)
        with_session do |session|
          cmd = {'$eval' => "function(){ return #{js}; }", nolock: true}
          session.command(cmd)['retval']
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

  rescue LoadError
    puts "Unable to find the moped gem, driver for MongoDB won't load."
  end

end
