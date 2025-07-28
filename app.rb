require 'bundler'
Bundler.require

require 'sinatra/base'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class App < Sinatra::Base
  get '/generate' do
    required_params = %i[qr_content line1 line2 line3]
    missing_params = required_params.reject { |p| params[p] }

    if missing_params.any?
      status 400
      content_type :json
      json({
        error: "Missing required parameters: #{missing_params.join(', ')}"
      })
      return
    end

    # Extract parameters with defaults
    qr_content = params[:qr_content]
    line1 = params[:line1]
    line2 = params[:line2]
    line3 = params[:line3]
    width = (params[:width] || 57).to_f
    height = (params[:height] || 32).to_f
    padding = (params[:padding] || 2.5).to_f

    # Use fixed path with timestamp from ENV or default
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    base_path = ENV['LABEL_OUTPUT_PATH'] || './'
    output_path = File.join(base_path, "label_#{timestamp}.pdf")

    # Generate the label
    label = HtmlLabel.new(
      qr_content:,
      line1:,
      line2:,
      line3:,
      width_mm: width,
      height_mm: height,
      padding_mm: padding
    )
    label.generate(output_path)

    # Send the PDF file
    send_file output_path,
      type: 'application/pdf',
      filename: 'label.pdf',
      disposition: 'inline'
  end

  run! if app_file == $0
end