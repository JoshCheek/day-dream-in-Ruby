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
  it 'basic parsing' do
    parses! 'x', terminals_include: 'x'
  end

  describe 'locals' do
  end
end
