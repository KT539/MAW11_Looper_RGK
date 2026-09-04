require 'bundler/setup'
require 'dotenv/load'
require 'sinatra'
require 'mysql2'
require 'fileutils'

PUBLIC_FOLDER = File.expand_path('Site_remastered', __dir__)
FIELDS_TEMPLATE_PATH = File.join(PUBLIC_FOLDER, 'exercises', 'template', 'fields.html')
FIELD_TYPES = %w[single_line single_line_list multi_line].freeze

DB = Mysql2::Client.new(
  host: ENV.fetch('DB_HOST'),
  username: ENV.fetch('DB_USERNAME'),
  password: ENV.fetch('DB_PASSWORD'),
  database: ENV.fetch('DB_DATABASE')
)

set :public_folder, PUBLIC_FOLDER

def fields_page_path(form_id)
  File.join(PUBLIC_FOLDER, 'exercises', form_id.to_s, 'fields.html')
end

def generate_fields_page(form_id)
  form = DB.prepare('SELECT name FROM forms WHERE id = ?').execute(form_id).first
  return false unless form

  labels = DB.prepare('SELECT label_name, type FROM labels WHERE form_id = ? ORDER BY id').execute(form_id)
  label_rows = labels.map do |label|
    <<~HTML
      <tr>
        <td>#{Rack::Utils.escape_html(label['label_name'])}</td>
        <td>#{Rack::Utils.escape_html(label['type'])}</td>
        <td></td>
      </tr>
    HTML
  end.join

  page_content = File.read(FIELDS_TEMPLATE_PATH)
    .sub('[Forms title]', Rack::Utils.escape_html(form['name']))
    .sub('<!-- LABEL_ROWS -->', label_rows)
    .sub('<!-- FIELD_FORM_ACTION -->', "http://localhost:4567/exercises/#{form_id}/fields")

  page_path = fields_page_path(form_id)
  FileUtils.mkdir_p(File.dirname(page_path))
  File.write(page_path, page_content)
  true
end

get '/' do
  redirect '/exercises/new.html'
end

post '/traitement' do
  title = params.dig('exercise', 'title').to_s.strip
  halt 422, 'Veuillez saisir un titre.' if title.empty?

  DB.prepare('INSERT INTO forms (name, status) VALUES (?, ?)').execute(title, 'Building')
  form_id = DB.last_id
  generate_fields_page(form_id)

  redirect "/exercises/#{form_id}/fields.html"
end

post '/exercises/:form_id/fields' do
  form_id = params[:form_id]
  halt 404, 'Exercice introuvable.' unless form_id.match?(/\d/)

  label_name = params.dig('field', 'label').to_s.strip
  value_kind = params.dig('field', 'value_kind').to_s
  halt 422, 'Veuillez saisir un libellé.' if label_name.empty?
  halt 422, 'Type de valeur invalide.' unless FIELD_TYPES.include?(value_kind)

  form_exists = DB.prepare('SELECT id FROM forms WHERE id = ?').execute(form_id).first
  halt 404, 'Exercice introuvable.' unless form_exists

  DB.prepare('INSERT INTO labels (label_name, type, form_id) VALUES (?, ?, ?)').execute(label_name, value_kind, form_id)
  generate_fields_page(form_id)

  redirect "/exercises/#{form_id}/fields.html"
end
