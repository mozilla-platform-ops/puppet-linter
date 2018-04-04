require 'yaml'

travis_yml = YAML.load_file('.travis.yml')

travis_yml["script"].each do |x|
  puts "Executing: #{x}"
  system(x)
  puts "Command exit code #{$?.exitstatus}"
end

