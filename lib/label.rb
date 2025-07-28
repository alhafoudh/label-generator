require 'rqrcode'

class Label
  attr_reader :qr_content, :line1, :line2, :line3, :width, :height, :x_margin, :y_margin

  def initialize(qr_content:, line1:, line2:, line3:, width: 57, height: 32, x_margin: 2.5, y_margin: 2.5)
    @qr_content = qr_content
    @line1 = line1
    @line2 = line2
    @line3 = line3
    @width = mm_to_p(width)
    @height = mm_to_p(height)
    @x_margin = mm_to_p(x_margin)
    @y_margin = mm_to_p(y_margin)
  end

  def generate(output_path = 'label.pdf')
    doc = HexaPDF::Document.new
    page = doc.pages.add
    page.box(:media, [0, 0, width, height])

    draw_content(page.canvas, doc)

    doc.write(output_path)
  end

  private

  def draw_content(canvas, doc)
    # Draw rectangle border
    border_width = width - x_margin * 2
    border_height = height - y_margin * 2
    canvas.rectangle(x_margin, y_margin, border_width, border_height).stroke

    # Calculate content area
    content_x = x_margin + mm_to_p(1)
    content_y = y_margin + mm_to_p(1)
    content_width = border_width - mm_to_p(2)
    content_height = border_height - mm_to_p(2)

    # Generate and draw QR code
    qr_size = [content_height, content_width * 0.4].min
    # Center QR code vertically
    qr_y = content_y + (content_height - qr_size) / 2
    draw_qr_code(canvas, content_x, qr_y, qr_size)

    # Draw text lines
    text_x = content_x + qr_size + mm_to_p(2)
    text_width = content_width - qr_size - mm_to_p(2)
    draw_text_lines(canvas, doc, text_x, content_y, text_width, content_height)
  end

  def draw_qr_code(canvas, x, y, size)
    qrcode = RQRCode::QRCode.new(qr_content)

    # Calculate module size
    module_count = qrcode.modules.length
    module_size = size / module_count.to_f

    # Draw QR code modules
    qrcode.modules.each_with_index do |row, row_index|
      row.each_with_index do |is_dark, col_index|
        if is_dark
          canvas.rectangle(
            x + col_index * module_size,
            y + (module_count - row_index - 1) * module_size,
            module_size,
            module_size
          ).fill
        end
      end
    end
  end

  def draw_text_lines(canvas, doc, x, y, width, height)
    # Font sizes
    line_font_size = mm_to_p(3.5)
    
    # Calculate line spacing
    line_spacing = height / 3.0
    
    # Setup fonts
    regular_font = doc.fonts.add('Helvetica')
    bold_font = doc.fonts.add('Helvetica', variant: :bold)
    
    # Create text layouter
    layouter = HexaPDF::Layout::TextLayouter.new
    
    # Draw line 1 (bold)
    fragments = [HexaPDF::Layout::TextFragment.create(line1, font: bold_font, font_size: line_font_size)]
    result = layouter.fit(fragments, width, line_spacing)
    result.draw(canvas, x, y + height - line_spacing)
    
    # Draw line 2 (regular)
    fragments = [HexaPDF::Layout::TextFragment.create(line2, font: regular_font, font_size: line_font_size)]
    result = layouter.fit(fragments, width, line_spacing)
    result.draw(canvas, x, y + line_spacing)
    
    # Draw line 3 (regular) 
    fragments = [HexaPDF::Layout::TextFragment.create(line3, font: regular_font, font_size: line_font_size)]
    result = layouter.fit(fragments, width, line_spacing)
    result.draw(canvas, x, y)
  end

  def mm_to_p(value)
    (value * 72.0 / 25.4).round(2)
  end
end