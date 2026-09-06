require 'mysql2'

# a module serves to regroup code under a single namespace
# here it's essentially a container for the connection method
module Database
  # self. makes connection a module method, kind of like a class method
  def self.connection
    # @ = instance variable, allowing the variable to persist between each call to Database.connection
    # ||= is a ruby operator : if @ connection is null, make a new connection and store it in memory for the next call
    @connection ||= Mysql2::Client.new(
      host: ENV.fetch('DB_HOST'),
      username: ENV.fetch('DB_USERNAME'),
      password: ENV.fetch('DB_PASSWORD'),
      database: ENV.fetch('DB_DATABASE')
    )
  end
end

