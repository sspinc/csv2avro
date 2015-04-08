require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'bump/tasks'

# Default directory to look in is `/spec`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
end

task :default => :spec

namespace :docker do
  desc "Build docker image"
  task :build => 'rake:build' do
    patch_version = CSV2Avro::VERSION
    %x( docker build -t csv2avro/#{patch_version} . )
    minor_version = patch_version.gsub(/\.[0-9]*$/, '')
    %x( docker tag csv2avro/#{patch_version} csv2avro/#{minor_version} )
    major_version = minor_version.gsub(/\.[0-9]*$/, '')
    %x( docker tag csv2avro/#{patch_version} csv2avro/#{major_version} )

    %x( docker tag csv2avro/#{patch_version} csv2avro/latest )
  end
end
