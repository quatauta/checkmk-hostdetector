# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

begin
  require 'bundler/gem_tasks'
rescue
end

namespace :doc do
  desc 'Build api docs with rdoc and yard if possible'
  task :all

  desc 'Delete generated docs'
  task :clobber
end

namespace :doc do
  begin
    require 'rdoc/task'

    task :all => [:rdoc]
    task :clobber => [:clobber_rdoc]
    Rake::RDocTask.new(:rdoc) do |task|
      task.rdoc_files.include('bin/**/*.rb', 'lib/**/*.rb', 'doc/*.md')
      task.rdoc_dir = 'doc/rdoc'
      task.options << '--all'
      task.options << '--charset=utf-8'
      task.options << '--hyperlink-all'
      task.options << '--inline-source'
      task.options << '--show-hash'
    end
  rescue LoadError
  end
end

namespace :doc do
  begin
    require 'yard'
    task :all => [:yard]
    YARD::Rake::YardocTask.new
  rescue LoadError
  end
end
