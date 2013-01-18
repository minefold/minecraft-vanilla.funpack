require 'json'

class TemplateContext

  attr_reader :level_name
  attr_reader :port

  def initialize(settings, level_name, port)
    @settings = settings
    @level_name = level_name || 'level'
    @port = port || 25565
  end

  def binding
    binding
  end

  def schema_path
    File.expand_path(File.join('..', '..', 'funpack.json'), __FILE__)
  end

  def schema
    JSON.load(schema_path)['settings']
  end

  def setting(name)
    @settings[name] || default(name)
  end

  def default(field_name)
    schema.find {|field| field['name'] == field_name }['default']
  end

end
