task :default => :test

task :test do
  system %Q{
    rm -rf tmp/world
    mkdir -p tmp/world
    cp -R test-world/* tmp/world
  }

  File.write 'tmp/world/settings.json', <<-EOS
{
  "options" : {
    "name": "minecraft-vanilla",
    "minecraft_version": "1.3.1",
    "ops": ["whatupdave"],
    "whitelisted": ["minefold_guest"],
    "banned": ["atnan"],
    "seed": 123456789,
    "spawn_animals": true,
    "spawn_monsters": true,
    "game_mode": 1
  }
}
  EOS

  system "bin/prepare tmp/world tmp/world/settings.json"
  system "bin/start tmp/world 4032 1024"
end