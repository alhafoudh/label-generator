require 'bundler'
Bundler.require

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('./lib', __dir__))
loader.setup

class LabelGenerator < Thor
  include Thor::Actions

  desc 'generate TEXT', 'Generate a label with the given name'

  def generate(text)
    label = Label.new(text)
    label.generate
  end
end
