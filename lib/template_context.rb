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

  def allow_nether
    settings['allow-nether'] ||
    settings['allow_nether'] == '1' ||
    settings['allow_nether'] == true ||
    default('allow-nether')
  end

  def allow_flight
    settings['allow-flight'] || settings['allow_flight'] || default('allow-flight')
  end

  def difficulty
    settings['difficulty'] || default('difficulty')
  end

  def enable_command_block
    settings['enable-command-block'] || settings['enable-command-block'] || default('enable-command-block')
  end

  def gamemode
    settings['gamemode'] || settings['game_mode'] || default('gamemode')
  end

  def generate_structures
    settings['generate-structures'] || settings['generate_structures'] || default('generate-structures')
  end

  def level_seed
    settings['level-seed'] || settings['seed']
  end

  def level_type
    settings['level-type'] || settings['level_type'] || default('level-type')
  end

  def pvp
    settings['pvp'] == '1' || settings['pvp'] == true || default('pvp')
  end

  def spawn_animals
    settings['spawn-animals'] || settings['spawn_animals'] == '1' || settings['spawn_animals'] == true || default('spawn-animals')
  end

  def spawn_monsters
    settings['spawn-monsters'] || settings['spawn_monsters'] == '1' || settings['spawn_monsters'] == true || default('spawn-monsters')
  end

  def spawn_npcs
    settings['spawn-npcs'] || settings['spawn_npcs'] == '1' || settings['spawn_npcs'] == true || default('spawn-npcs')
  end

  # TODO Validate that it's actually a remote URL
  def texture_pack
    settings['texture-pack']
  end

end
