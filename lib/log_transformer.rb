require 'json'

class LogTransformer

  GAME_MODES = %w(Survival Creative Adventure)
  DIFFICULTIES = %w(Peaceful Easy Normal Hard)

  def initialize(io)
    @io = io
  end

  def process!
    until @io.eof?
      process(@io.readline)
    end
  end

  def process(str)
    line = str.force_encoding('ISO-8859-1')
    # Remove color sequences
    line.gsub! /\e\[\d+m/, ''
    # Remove garbage prefix
    line.gsub! /[\d-]+ [\d:]+ \[[A-Z]+\]\s/, ''
    line.strip!

    # Minecraft prints player lists across multiple lines so a seperate mode
    # is needed.
    if @player_list_mode
      @players += line.split(',').map {|player| player.strip }
      
      puts "#{@players} #{@players_count}"

      if @players.size == @players_count
        @player_list_mode = false
        trigger :players, players: @players, count: @players.count
      end

      return
    end

    case
    when line =~ /^Done \(([\.0-9]+)s\)!/
      trigger :started, elapsed: ($1.to_f * 1000).to_i

    when line.include?('Stopping server')
      trigger :stopping

    when line =~ /^(\w+).*logged in with entity id/
      trigger :player_connected, username: $1

    when line =~ /^(\w+) lost connection: (.*)$/
      trigger :player_disconnected, username: $1, reason: $2

    when line =~ /^<(\w+)> (.+)$/
      trigger :chat, player: $1, msg: $2

    when line =~ /^There are (\d+)\/(\d+) players online:$/
      @player_list_mode = true
      @players_count = $1.to_i
      @players = []

    when line =~ /^\[(\w+)\: (.*)\]$/
      actor = $1
      key, value = parse_settings($2)
      trigger :settings_changed, actor: actor, key: key, value: value

    when line.include?('FAILED TO BIND TO PORT!')
      trigger :fatal_error
      Process.kill :TERM, @io.pid

    else
      trigger :info, msg: line

    end
  end

  def trigger(event, options = {})
    payload = {
      ts: Time.now.utc.iso8601,
      event: event,
      pid: @io.pid
    }.merge(options)

    STDOUT.puts(payload.to_json)
  end

# private

  # Extracts [key, value] pairs of settings for their console messages
  def parse_settings(msg)
    case msg
    when /Added (\w+) to the whitelist/
      [:whitelist_add, $1]

    when /Removed (\w+) from the whitelist/
      [:whitelist_remove, $1]

    when /Banned player (\w+)/
      [:blacklist_add, $1]

    when /Unbanned player (\w+)/
      [:blacklist_remove, $1]

    when /Opped (\w+)/
      [:ops_add, $1]

    when /De-opped (\w+)/
      [:ops_remove, $1]

    when /default game mode is now (\w+)/
      [:game_mode, GAME_MODES.index($1)]

    when /Set game difficulty to (\w+)/
      [:difficulty, DIFFICULTIES.index($1)]
    end
  end

end
