require 'sinatra/base'
require_relative '../models/form'
require_relative '../models/label'
require_relative '../services/fields_page_generator'
require_relative '../helpers/directory_cleanup'

class App < Sinatra::Base
  PUBLIC_FOLDER = File.expand_path('../../Site_remastered', __dir__)
  EXERCISES_FOLDER = File.join(PUBLIC_FOLDER, 'exercises')
  FIELD_TYPES = %w[single_line single_line_list multi_line].freeze

  set :public_folder, PUBLIC_FOLDER

  get '/' do
    redirect '/index.html'
  end

  post '/traitement' do
    title = params.dig('exercise', 'title').to_s.strip
    halt 422, 'Veuillez saisir un titre.' if title.empty?

    form_id = Form.create(title, 'Building')
    FieldsPageGenerator.call(form_id)
    redirect "/exercises/#{form_id}/fields.html"
  end

  post '/exercises/:form_id/fields' do
    form_id = params[:form_id]
    halt 404, 'Exercice introuvable.' unless form_id.match?(/\d/)
    halt 404, 'Exercice introuvable.' unless Form.find(form_id)

    label_name = params.dig('field', 'label').to_s.strip
    value_kind = params.dig('field', 'value_kind').to_s
    halt 422, 'Veuillez saisir un libellé.' if label_name.empty?
    halt 422, 'Type de valeur invalide.' unless FIELD_TYPES.include?(value_kind)

    Label.create(label_name, value_kind, form_id)
    FieldsPageGenerator.call(form_id)
    redirect "/exercises/#{form_id}/fields.html"
  end

  post '/exercises/:form_id/complete' do
    form_id = params[:form_id]
    halt 404, 'Exercice introuvable.' unless form_id.match?(/\d/)
    halt 404, 'Exercice introuvable.' unless Form.find(form_id)

    Form.update_status(form_id, 'Answering')
    DirectoryCleanup.remove(File.join(EXERCISES_FOLDER, form_id.to_s))
    DirectoryCleanup.remove_expired(EXERCISES_FOLDER)
    redirect '/exercises.html'
  end
end

