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
    "minecraft_version": "HEAD",
    "ops": ["chrislloyd"],
    "whitelisted": ["whatupdave"],
    "banned": ["atnan"]
  }
}
  EOS

  system "bin/prepare tmp/world tmp/world/settings.json"
  system "bin/start tmp/world 4032 1024"
end