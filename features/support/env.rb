# Generated by cucumber-sinatra. (2013-09-23 12:45:56 +0100)

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', '..', 'lib/sudoku.rb')

require 'capybara'
require 'capybara/cucumber'
require 'rspec'

Capybara.app = Sudoku

class SudokuWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  SudokuWorld.new
end
