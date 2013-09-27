# -*- coding: UTF-8; -*-
# vim:set fileencoding=UTF-8:

begin
  require 'bundler/gem_tasks'
  require 'rdoc/task'
  require 'yard'
rescue
end

if Rake.const_defined? :RDocTask
namespace :doc do
  Rake::RDocTask.new(:rdoc) do |task|
    task.options + ['-a', '--inline-source', '--charset=UTF-8']
  end
end
end

if Module.const_defined?(:YARD) && YARD.const_defined?(:Rake) && YARD::Rake.const_defined?(:YardocTask)
  namespace :doc do
    YARD::Rake::YardocTask.new(:yard) do |task|
    end
  end
end
