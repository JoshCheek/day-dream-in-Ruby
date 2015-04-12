require 'stringio'
require_relative 'helpers'

module SpecHelpers
  class << self
    attr_accessor :parser_class
  end

  @parser_class = BuildTheParser \
    grammar_file: 'whatevz.treetop',
    compile:      true

  def parses!(body, assertions)
    ast! parse(body), assertions
  end

  def parse(body)
    Parse body:         body,
          parser_class: SpecHelpers.parser_class,
          errstream:    StringIO.new,
          pry:          false
  end

  def ast!(ast, assertions)
    terminals = get_terminals ast
    Array(assertions[:terminals_include]).each do |expected|
      expect(terminals).to include expected
    end
  end

  def get_terminals(ast)
    return ast.text_value if ast.terminal?
    ast.elements.flat_map { |child| get_terminals child }
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end

RSpec.describe 'My language' do
  class << self
    alias are it
  end

  example 'sanity test: some basic parsing' do
    parses! 'x', terminals_include: 'x'
  end

  context 'entry locations' do
    it 'exports named classes'
    it 'exports anonymous functions to call'
  end

  context 'self' do
    it 'is represented with @'
    it 'calls methods on self with @.method'
  end

  context 'the assigment arrow' do
    it 'assigns locals'
    it 'assigns ivars'
    it 'calls setters'
  end

  context 'blocks' do
    are 'indicated by an arg list and inline body'
    are 'indicated by an arg list and indentation'
    are 'indicated by indentation without an arg list'
  end

  context 'local variables' do
  end

  context 'argument lists' do
    are 'indicated by parentheses'
    #...
  end
end
