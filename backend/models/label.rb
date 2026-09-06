require_relative '../config/database'

class Label
  def self.all_for_form(form_id)
    Database.connection.prepare('SELECT label_name, type FROM labels WHERE form_id = ? ORDER BY id')
    Database.connection.execute(form_id)
  end

  def self.create(label_name, type, form_id)
    Database.connection.prepare('INSERT INTO labels (label_name, type, form_id) VALUES (?, ?, ?)')
    Database.connection.execute(label_name, type, form_id)
  end
end

