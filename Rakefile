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
