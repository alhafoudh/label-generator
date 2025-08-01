require 'rqrcode'
require 'erb'
require 'cgi'
require 'ferrum'

class HtmlLabel
  attr_reader :params
  attr_reader :before_generate_block

  def initialize(params = {})
    @params = params.transform_keys(&:to_sym)
  end

  def generate(output_path = 'label.pdf', format: :pdf)
    html_content = generate_html

    # Save HTML for debugging
    File.write('label.html', html_content)

    # Generate PDF or PNG from HTML using Ferrum
    browser = Ferrum::Browser.new(
      process_timeout: ENV.fetch('FERRUM_PROCESS_TIMEOUT', 60).to_i,
      headless: true,
      browser_options: { "no-sandbox": nil },
    )
    begin
      page = browser.create_page
      page.content = html_content
      before_generate_block.call(page) if before_generate_block

      if format.to_sym == :png
        page.screenshot(path: output_path, full: true)
      else
        # Generate PDF (default)
        page.pdf(
          path: output_path,
          format: :A4,
          landscape: false,
          margin: { top: 0, right: 0, bottom: 0, left: 0 },
          preferCSSPageSize: true,
          printBackground: true
        )
      end
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

  def qr_svg(content)
    qrcode = RQRCode::QRCode.new(content)
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

  def before_generate(&block)
    @before_generate_block = block
  end

  def h(text)
    CGI.escapeHTML(text)
  end
end