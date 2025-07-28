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

    draw_content(page.canvas)

    doc.write(output_path)
  end

  private

  def draw_content(canvas)
    # Draw rectangle border
    canvas.rectangle(x_margin, y_margin, width - x_margin - mm_to_p(0.5), height - y_margin - mm_to_p(0.5)).stroke

    # Draw text
    canvas.
      font('Helvetica', variant: :bold, size: mm_to_p(5)).
      text(text, at: [x_margin, height - mm_to_p(5)])
  end

  def mm_to_p(value)
    (value * 72.0 / 25.4).round(2)
  end
end