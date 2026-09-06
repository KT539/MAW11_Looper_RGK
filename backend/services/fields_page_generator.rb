require 'fileutils'
require 'rack/utils'
require_relative '../models/form'
require_relative '../models/label'

module FieldsPageGenerator
  PUBLIC_FOLDER = File.expand_path('../../Site_remastered', __dir__)
  EXERCISES_FOLDER = File.join(PUBLIC_FOLDER, 'exercises')
  TEMPLATE_PATH = File.join(EXERCISES_FOLDER, 'template', 'fields.html')

  def self.call(form_id)
    form = Form.find(form_id)
    return false unless form

    labels = Label.all_for_form(form_id)

    label_rows = ''
    labels.each do |label|
      label_rows += "<tr>\n"
      label_rows += "  <td>#{Rack::Utils.escape_html(label['label_name'])}</td>\n"
      label_rows += "  <td>#{Rack::Utils.escape_html(label['type'])}</td>\n"
      label_rows += "  <td></td>\n"
      label_rows += "</tr>\n"
    end

    page_content = File.read(TEMPLATE_PATH)
    page_content = page_content.sub('[Forms title]', Rack::Utils.escape_html(form['name']))
    page_content = page_content.sub('<!-- LABEL_ROWS -->', label_rows)
    page_content = page_content.sub('<!-- FIELD_FORM_ACTION -->', "http://localhost:4567/exercises/#{form_id}/fields")
    page_content = page_content.sub('<!-- COMPLETE_FORM_ACTION -->', "http://localhost:4567/exercises/#{form_id}/complete")

    form_directory = File.join(EXERCISES_FOLDER, form_id.to_s)
    page_path = File.join(form_directory, 'fields.html')
    FileUtils.mkdir_p(form_directory)
    File.write(page_path, page_content)

    true
  end
end

