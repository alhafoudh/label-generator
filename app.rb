require 'bundler'
Bundler.require

require 'sinatra/base'
require 'sinatra/reloader'
require 'shellwords'
require 'tempfile'
require 'childprocess'

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

  [:get, :post].map do |method|
    send(method, '/generate.:format?') do
      if method == :post
        params.merge!(JSON.parse(request.body.read))
      end

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
  end

  post '/print' do
    # Check if file was uploaded
    unless params[:file] && params[:file][:tempfile]
      status 400
      content_type 'application/json'
      return { error: 'No file uploaded' }.to_json
    end

    # Check if printer name is provided
    unless params[:printer_name]
      status 400
      content_type 'application/json'
      return { error: 'Printer name is required' }.to_json
    end

    uploaded_file = params[:file][:tempfile]
    printer_name = params[:printer_name]

    # Use Tempfile with do block for automatic cleanup
    Tempfile.open(%w[print_ .tmp]) do |temp_file|
      temp_file.binmode
      temp_file.write(uploaded_file.read)
      temp_file.flush

      # Execute lpr command to print the file and capture output using ChildProcess
      Tempfile.open(%w[stdout_ .tmp]) do |stdout_file|
        Tempfile.open(%w[stderr_ .tmp]) do |stderr_file|
          process = ChildProcess.build('lpr', '-P', printer_name, temp_file.path)
          process.io.stdout = stdout_file
          process.io.stderr = stderr_file
          process.start
          process.wait

          stdout_file.rewind
          stderr_file.rewind
          stdout_content = stdout_file.read
          stderr_content = stderr_file.read
          exit_code = process.exit_code

          content_type 'application/json'
          response = {
            success: exit_code == 0,
            exit_code: exit_code,
            stdout: stdout_content,
            stderr: stderr_content,
            message: exit_code == 0 ? "File sent to printer: #{printer_name}" : "Failed to print file on printer: #{printer_name}"
          }

          unless exit_code == 0
            self.status 500
          end

          response.to_json
        end
      end
    end

  rescue => e
    logger.error "Error printing file: #{e.message}"
    logger.error e.backtrace.join("\n")

    status 500
    content_type 'application/json'
    { error: e.message }.to_json
  end

  run! if app_file == $0
end