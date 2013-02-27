# encoding: UTF-8

require 'json'

class LogProcessor
  def initialize(pid)
    @pid = pid
    @mode = :normal
  end

  def process_line(line)
    line = line.force_encoding('ISO-8859-1').
      gsub(/\e\[\d+m/, ''). # strip color sequences out
      gsub(/[\d-]+ [\d:]+ \[[A-Z]+\]\s/, ''). # strip time prefix
      strip
    
      result = case @mode
      when :normal
        process_normal_line(line)
      when :player_list
        process_player_list_line(line)
      end
  end
  
  def process_normal_line(line)
    case line
    when /^Done \(([\.0-9]+)s\)!/
      trigger :started, elapsed: ($1.to_f * 1000).to_i

    when /Stopping server/
      trigger :stopping

    when /^(\w+).*logged in with entity id/
      trigger :player_connected, auth: 'mojang', uid: $1

    when /^(\w+) lost connection: (.*)$/
      trigger :player_disconnected, auth: 'mojang', uid: $1, reason: $2

    when /^<(\w+)> (.+)$/
      trigger :chat, nick: $1, msg: $2

    when /^There are (\d+)\/(\d+) players online:$/
      @mode = :player_list
      @players_count = $1.to_i
      @players = []

    when /^\[(\w+)\: (.*)\]$/
      actor = $1
      update = parse_settings($2).merge(actor: actor)
      trigger :settings_changed, update

    when /FAILED TO BIND TO PORT!/
      trigger :fatal_error
      Process.kill :TERM, @pid

    when /^java.lang.OutOfMemoryError: Java heap space$/
      trigger :fatal_error, reason: 'out_of_memory'
      Process.kill :TERM, @pid

    when /^\[SEVERE\] This crash report has been saved to:/
      trigger :fatal_error
      Process.kill :TERM, @pid

    else
      trigger :info, msg: line

    end
  end
  
  def process_player_list_line(line)
    line_players = line.split(',').map(&:strip)
    @players += line_players
    if @players.size == @players_count || line_players.size == 0
      trigger 'players_list', auth: 'mojang', uids: @players
      @mode = :normal
    end
    true
  end

  def trigger(event, options = {})
    payload = {
      ts: Time.now.utc.iso8601,
      event: event
    }.merge(options)

    STDOUT.puts(payload.to_json)
  end

# private

  # Extracts [key, value] pairs of settings for their console messages
  def parse_settings(msg)
    case msg
    when /Added (\w+) to the whitelist/
      { add: 'whitelist', value: $1 }

    when /Removed (\w+) from the whitelist/
      { remove: 'whitelist', value: $1 }

    when /Banned player (\w+)/
      { add: 'blacklist', value: $1 }

    when /Unbanned player (\w+)/
      { remove: 'whitelist', value: $1 }

    when /Opped (\w+)/
      { add: 'ops', value: $1 }

    when /De-opped (\w+)/
      { remove: 'ops', value: $1 }

    when /default game mode is now (\w+)/
      { set: 'gamemode', value: GAME_MODES.index($1) }

    when /Set game difficulty to (\w+)/
      { set: 'difficulty', value: DIFFICULTIES.index($1) }
    end
  end
end
