require_relative '../config/database'

class Form
  def self.find(id)
    # use .first to extract the first element of the result returned by .execute
    Database.connection.prepare('SELECT * FROM forms WHERE id = ?').execute(id).first
  end

  def self.create(name, status)
    Database.connection.prepare('INSERT INTO forms (name, status) VALUES (?, ?)').execute(name, status)
    Database.connection.last_id
  end

  def self.update_status(id, status)
    Database.connection.prepare('UPDATE forms SET status = ? WHERE id = ?').execute(status, id)
  end
end

