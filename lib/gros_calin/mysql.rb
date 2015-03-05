module GrosCalin

  begin

    require 'mysql2'

    class Mysql
      include Driver
      register 'mysql'

      def query(id, sql)
        Mysql2::Client.new(@options).query(sql).each
      end
    end

  rescue LoadError
    puts "Unable to find the mysql2 gem, driver for MySQL won't load."
  end

end
