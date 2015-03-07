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

    end

  rescue LoadError
    puts "Unable to find the moped gem, driver for MongoDB won't load."
  end

end
