require 'bundler'
Bundler.require

require 'json'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class LabelGenerator < Thor
  include Thor::Actions

  desc 'generate JSON_PARAMS', 'Generate a label from JSON parameters'
  option :format, type: :string, default: 'pdf', desc: 'Output format (pdf or png)'

  def generate(json_params)
    begin
      params = JSON.parse(json_params)
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e.message}"
      exit 1
    end
    
    format = options[:format].downcase
    file_extension = format == 'png' ? '.png' : '.pdf'
    output_path = "label#{file_extension}"
    
    label = HtmlLabel.new(params)
    label.generate(output_path, format: format.to_sym)
  end
end
