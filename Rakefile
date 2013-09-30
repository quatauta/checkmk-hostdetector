# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

namespace :gem do
  begin
    require 'bundler/gem_tasks'
  rescue
  end
end

namespace :doc do
  begin
    require 'rdoc/task'

    task :clobber => :clobber_rdoc
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
    YARD::Rake::YardocTask.new
  rescue LoadError
  end
end

namespace :metric do
  begin
    require 'cane/rake_task'
    desc "Run cane to check quality metrics"
    Cane::RakeTask.new(:cane) do |cane|
      cane.abc_max = 10
      cane.add_threshold 'coverage/covered_percent', :>=, 99
      cane.no_style = true
      cane.abc_exclude = %w(Foo::Bar#some_method)
    end

  rescue LoadError
    warn "cane not available, quality task not provided."
  end
end

namespace :metric do
  begin
    require 'rubocop/rake_task'
    Rubocop::RakeTask.new(:rubocop) do |task|
      task.patterns = ['Rakefile', 'bin/**/*.rb', 'config/**.rb', 'lib/**/*.rb']
      task.fail_on_error = false
    end
  rescue LoadError
  end
end
