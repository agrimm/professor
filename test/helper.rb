require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'professor'

class Test::Unit::TestCase
end

module TestProfessorHelper
  def create_comparison_using_filenames(old_rdoc_filename, new_rdoc_filename)
    comparison = Professor.create_comparison(old_rdoc_filename, new_rdoc_filename)
  end
end
