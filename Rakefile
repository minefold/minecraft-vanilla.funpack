task :default => :test

task :test do
  world = 'test-world'
  if ENV['WORLD']
    world = "tmp/#{ENV['WORLD']}"
  end

  system %Q{
    rm -rf tmp/world
    mkdir -p tmp/world
    cp -R #{world}/* tmp/world
  }

  File.write 'tmp/settings.json', <<-EOS
  {
    "port": 4032,
    "ram": {
      "min": 1024,
      "max": 1024
    },
    "settings" : {
      "blacklist": "atnan",
      "game_mode": 1,
      "new_player_can_build" : false,
      "ops": "chrislloyd\\nwhatupdave",
      "seed": 123456789,
      "spawn_animals": true,
      "spawn_monsters": true,
      "whitelist": "whatupdave"
    }
  }
  EOS

  run = File.expand_path 'bin/run'

  Dir.chdir('tmp/world') do
    raise "error" unless system "#{run} ../settings.json"
  end
end

task :download do
  abort "WORLD required" unless ENV['WORLD']
  world_id = ENV['WORLD']
  system "s3cmd get s3://minefold-production/worlds/#{world_id}/world-data.incremental.tar tmp/#{world_id}.tar"
  system "mkdir -p tmp/#{world_id}; tar xf tmp/#{world_id}.tar -C tmp/#{world_id}"
  system "rm -f tmp/#{world_id}.tar"
end

task :upload_patch do
  abort "WORLD required" unless ENV['WORLD']
  world_id = ENV['WORLD']
  tar_file = "tmp/#{world_id}.#{Time.now.to_i}.patch.tar"
  system "tar cf #{tar_file} -C tmp/#{world_id} ."
  system "s3cmd put #{tar_file} s3://minefold-production/worlds/#{world_id}/#{world_id}.#{Time.now.to_i}.patch.tar"
  system "rm -f #{tar_file}"
end