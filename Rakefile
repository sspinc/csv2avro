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

namespace :docker do
  desc "Build docker image"
  task :build do
    sh "docker build -t sspinc/csv2avro:#{CSV2Avro::VERSION} ."
    minor_version = CSV2Avro::VERSION.sub(/\.[0-9]+$/, '')
    sh "docker tag -f sspinc/csv2avro:#{CSV2Avro::VERSION} sspinc/csv2avro:#{minor_version}"
    major_version = minor_version.sub(/\.[0-9]+$/, '')
    sh "docker tag -f sspinc/csv2avro:#{CSV2Avro::VERSION} sspinc/csv2avro:#{major_version}"

    sh "docker tag -f sspinc/csv2avro:#{CSV2Avro::VERSION} sspinc/csv2avro:latest"
  end

  desc "Run specs inside docker image"
  task :spec => :build do
    sh "docker run --entrypoint=rake sspinc/csv2avro:#{CSV2Avro::VERSION} spec"
  end

  desc "Push docker image"
  task :push => :spec do
    sh "docker push sspinc/csv2avro"
  end
end
