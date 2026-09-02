require 'bundler/setup'
require 'dotenv/load'
require 'sinatra'
require 'mysql2'
require 'fileutils'

client = Mysql2::Client.new(:host => ENV['DB_HOST'], :username => ENV['DB_USERNAME'], :password => ENV['DB_PASSWORD'], :database => ENV['DB_DATABASE'])

# Rend le dossier du site accessible depuis le même serveur que l'application Ruby.
set :public_folder, File.expand_path('Site_remastered', __dir__)

get '/' do
  redirect '/exercises/new.html'
end

post '/traitement' do
  title = params.dig('exercise', 'title').to_s.strip

  halt 422, 'Veuillez saisir un titre.' if title.empty?

  # La requête préparée protège la base des caractères spéciaux et injections SQL.
  client.prepare('INSERT INTO forms (name, status) VALUES (?, ?)').execute(title, 'Building')
  form_id = client.last_id

  template_path = File.join(settings.public_folder, 'exercises', 'template', 'fields.html')
  page_path = File.join(settings.public_folder, 'exercises', form_id.to_s, 'fields.html')
  page_content = File.read(template_path).sub('[Forms title]', Rack::Utils.escape_html(title))

  FileUtils.mkdir_p(File.dirname(page_path))
  File.write(page_path, page_content)

  redirect "/exercises/#{form_id}/fields.html"
end
