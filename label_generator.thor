require 'bundler'
Bundler.require

require 'json'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class LabelGenerator < Thor
  include Thor::Actions

  desc 'generate JSON_PARAMS', 'Generate a label from JSON parameters'
  option :format, type: :string, default: 'pdf', desc: 'Output format (pdf, png, or html)'

  def generate(json_params)
    begin
      params = JSON.parse(json_params)
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e.message}"
      exit 1
    end
    
    format = options[:format].downcase
    file_extension = case format
                    when 'png' then '.png'
                    when 'html' then '.html'
                    else '.pdf'
                    end
    output_path = "label#{file_extension}"
    
    label = HtmlLabel.new(params)
    result = label.generate(output_path, format: format.to_sym)
    
    if format == 'html'
      puts result
    end
  end
end
