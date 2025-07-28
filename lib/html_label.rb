require 'rqrcode'
require 'erb'
require 'cgi'
require 'ferrum'

class HtmlLabel
  attr_reader :qr_content, :line1, :line2, :line3

  def initialize(qr_content:, line1:, line2:, line3:)
    @qr_content = qr_content
    @line1 = line1
    @line2 = line2
    @line3 = line3
  end

  def generate(output_path = 'label.pdf')
    html_content = generate_html

    # Save HTML for debugging
    File.write('label.html', html_content)

    # Generate PDF from HTML using Ferrum
    browser = Ferrum::Browser.new(headless: true)
    begin
      page = browser.create_page
      page.content = html_content
      page.pdf(
        path: output_path,
        format: :A4,
        landscape: false,
        margin: { top: 0, right: 0, bottom: 0, left: 0 },
        preferCSSPageSize: true,
        printBackground: true
      )
    ensure
      browser.quit
    end
  end

  private

  def generate_html
    template_path = File.expand_path('./label.html.erb', __dir__)
    template = ERB.new(File.read(template_path))
    template.result(binding)
  end

  def qr_svg
    qrcode = RQRCode::QRCode.new(qr_content)
    qrcode.as_svg(
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 2,
      standalone: true,
      use_path: true,
      viewbox: true,
      svg_attributes: { class: 'qr-code' }
    )
  end

  def h(text)
    CGI.escapeHTML(text)
  end
end