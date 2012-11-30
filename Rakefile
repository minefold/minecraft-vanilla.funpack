task :default => :test

task :test do
  system %Q{
    rm -rf tmp/world
    cp -R test/fixtures/world tmp/world
    cp test/fixtures/bad.json tmp/settings.json
    cd tmp/world
    ../../bin/run ../settings.json
  }
end
