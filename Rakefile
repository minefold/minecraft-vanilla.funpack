task :default => :test

task :test do
  system %Q{
    rm -rf tmp/world
    mkdir -p tmp/world
    cp -R test/fixtures/world/* tmp/world
    cp test/fixtures/ok.json tmp/settings.json
    cd tmp/world
    ../../bin/run ../settings.json
  }
end

task :publish do
  paths = %w(bin lib templates Gemfile Gemfile.lock funpack.json)
  system %Q{
    archive-dir http://party-cloud-production.s3.amazonaws.com/funpacks/slugs/minecraft/stable.tar.lzo #{paths.join(' ')}
  }
end