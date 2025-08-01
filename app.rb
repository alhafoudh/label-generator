require 'bundler'
Bundler.require

require 'sinatra/base'
require 'sinatra/reloader'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class App < Sinatra::Base
  configure do
    set :logging, Logger::INFO
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/generate.:format?' do
    # Extract format from URL extension, default to pdf
    format = (params[:format] || 'pdf').downcase

    begin
      # Use fixed path with timestamp from ENV or default
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      base_path = ENV['LABEL_OUTPUT_PATH'] || './'

      # Determine file extension and output path
      file_extension = case format
      when 'png' then '.png'
      when 'pdf' then '.pdf'
      else '.html'
      end
      output_path = File.join(base_path, "label_#{timestamp}#{file_extension}")

      # Generate the label
      label = HtmlLabel.new(params)
      result = label.generate(output_path, format: format.to_sym)

      # Handle response based on format
      case format
      when 'html'
        content_type 'text/html'
        result
      when 'png'
        send_file(output_path, type: 'image/png', filename: 'label.png', disposition: 'inline')
      else
        send_file(output_path, type: 'application/pdf', filename: 'label.pdf', disposition: 'inline')
      end
    rescue => e
      logger.error "Error generating label: #{e.message}"
      logger.error e.backtrace.join("\n")

      status 500
      content_type 'application/json'
      { error: e.message }.to_json
    end
  end

  run! if app_file == $0
end