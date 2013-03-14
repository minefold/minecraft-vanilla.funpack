require 'json'

task :default => :start

$build_dir = File.expand_path("~/funpacks/minecraft/build")
$cache_dir = File.expand_path("~/funpacks/minecraft/cache")
$working_dir = File.expand_path(ENV['WORKING'] || "~/funpacks/minecraft/working")

task :start do
  system %Q{
    mkdir -p #{$working_dir}
  }

  data = {
    name: "Woodbury",
    settings: {
      'gamemode' => 2,
      'ops' => "chrislloyd",
      'whitelist' => "whatupdave\r\natnan",
      'level-seed' => "s33d",
      'allow-nether' => true,
      'allow-flight' => false,
      'spawn-animals' => true,
      'spawn-monsters' => false,
      'spawn-npcs' => false,
    }
  }

  Dir.chdir($working_dir) do
    raise "error" unless system "BUNDLE_GEMFILE=#{$build_dir}/Gemfile PORT=4032 RAM=638 DATA=#{data.to_json.to_json} #{$build_dir}/bin/run 2>&1"
  end
end

task :compile do
  fail unless system "rm -rf #{$build_dir} && mkdir -p #{$build_dir} #{$cache_dir}"
  fail unless system "bin/compile #{$build_dir} #{$cache_dir} 2>&1"
  Dir.chdir($build_dir) do
    if !system("bundle check")
      fail unless system "bundle install --deployment 2>&1"
    end
  end
end

task :import do
  fail unless system "cd #{$working_dir}/.. && #{$build_dir}/bin/import"
end
