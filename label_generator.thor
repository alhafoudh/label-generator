require 'bundler'
Bundler.require

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class LabelGenerator < Thor
  include Thor::Actions

  desc 'generate QR_CONTENT LINE1 LINE2 LINE3', 'Generate a label with QR code and 3 lines of text'

  def generate(qr_content, line1, line2, line3)
    label = Label.new(
      qr_content: qr_content,
      line1: line1,
      line2: line2,
      line3: line3
    )
    label.generate
    puts "Label generated: label.pdf"
  end
end
