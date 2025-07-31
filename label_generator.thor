require 'bundler'
Bundler.require

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class LabelGenerator < Thor
  include Thor::Actions

  desc 'generate QR_CONTENT LINE1 LINE2 LINE3', 'Generate an HTML label with QR code and 3 lines of text'
  option :width, type: :numeric, default: 57, desc: 'Label width in mm'
  option :height, type: :numeric, default: 32, desc: 'Label height in mm'
  option :padding, type: :numeric, default: 2.5, desc: 'Label padding in mm'
  option :format, type: :string, default: 'pdf', desc: 'Output format (pdf or png)'

  def generate(qr_content, line1, line2, line3)
    format = options[:format].downcase
    file_extension = format == 'png' ? '.png' : '.pdf'
    output_path = "label#{file_extension}"
    
    label = HtmlLabel.new(
      qr_content: qr_content,
      line1:,
      line2:,
      line3:,
      width_mm: options[:width],
      height_mm: options[:height],
      padding_mm: options[:padding]
    )
    label.generate(output_path, format: format.to_sym)
  end
end
