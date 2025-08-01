require 'bundler'
Bundler.require

require 'sinatra/base'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class App < Sinatra::Base
  get '/generate' do
    # Extract format parameter
    format = (params[:format] || 'pdf').downcase

    begin
      # Use fixed path with timestamp from ENV or default
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      base_path = ENV['LABEL_OUTPUT_PATH'] || './'
      file_extension = format == 'png' ? '.png' : '.pdf'
      output_path = File.join(base_path, "label_#{timestamp}#{file_extension}")

      # Generate the label
      label = HtmlLabel.new(params)
      label.generate(output_path, format: format.to_sym)

      # Send the file with appropriate content type
      content_type = format == 'png' ? 'image/png' : 'application/pdf'
      filename = format == 'png' ? 'label.png' : 'label.pdf'

      send_file(
        output_path,
        type: content_type,
        filename: filename,
        disposition: 'inline',
      )
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