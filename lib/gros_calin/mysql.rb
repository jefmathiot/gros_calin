module GrosCalin

  begin

    require 'mysql2'

    class Mysql
      include Driver
      register 'mysql'

      def query(id, sql)
        Mysql2::Client.new(@options).query(sql).map do |row|
          {}.tap do |result|
            row.each do|key, value|
              result[key] = value.is_a?(BigDecimal) ? value.to_f : value
            end
          end
        end
      end
    end

  rescue LoadError
    puts "Unable to find the mysql2 gem, driver for MySQL won't load."
  end

end
