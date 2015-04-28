require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'bump/tasks'

# Remove pre and set rake tasks
Rake.application.instance_eval do
  %w[bump:pre bump:set].each do |task|
    @tasks.delete(task)
  end
end

# Default directory to look in is `/spec`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
end

task :default => :spec

task :build do
  sh "ln -f pkg/csv2avro-#{CSV2Avro::VERSION}.gem pkg/csv2avro-latest.gem"
end

namespace :docker do
  desc "Build docker image"
  task :build => "rake:build" do
    sh "docker build -t sspinc/csv2avro:#{CSV2Avro::VERSION} ."
    minor_version = CSV2Avro::VERSION.sub(/\.[0-9]+$/, '')
    sh "docker tag -f sspinc/csv2avro:#{CSV2Avro::VERSION} sspinc/csv2avro:#{minor_version}"
    major_version = minor_version.sub(/\.[0-9]+$/, '')
    sh "docker tag -f sspinc/csv2avro:#{CSV2Avro::VERSION} sspinc/csv2avro:#{major_version}"

    sh "docker tag -f sspinc/csv2avro:#{CSV2Avro::VERSION} sspinc/csv2avro:latest"
  end

  desc "Push docker image"
  task :push => "build" do
    sh "docker push sspinc/csv2avro"
  end
end
