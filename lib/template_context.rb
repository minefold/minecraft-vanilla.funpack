require 'yaml'

class TemplateContext

  attr_reader :level_name, :port, :settings

  def initialize(settings, level_name, port)
    @settings = settings
    @level_name = level_name || 'level'
    @port = port || 25565
  end

  def context
    binding
  end

  def settings_config_path
    File.expand_path(File.join('..', '..', 'config', 'settings.yaml'), __FILE__)
  end

  def default(name)
    YAML.load(File.read(settings_config_path))
      .find {|s| s['name'] == name }['default']
  end

  def setting(name)
    possible_keys = [name, name.gsub('-', '_')]
    key = possible_keys.find{|key| settings.include?(key) }
    settings[key] if key
  end

  def bool(name)
    value = setting(name)

    if !value.nil?
      ['1', 'true', true].include?(value)
    else
      default(name)
    end
  end
end
