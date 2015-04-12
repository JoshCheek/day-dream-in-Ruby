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
    ast! parse(body, errstream: $stderr), assertions
  end

  def parse(body, errstream: StringIO.new)
    parse_tree = Parse body:         body,
                       parser_class: SpecHelpers.parser_class,
                       errstream:    errstream,
                       pry:          false
    parse_tree.to_ast
  end

  def ast!(ast, assertions)
    asrts = assertions.dup
    first_ast = ast.expressions.first

    # assertions about the first node
    if (expected = asrts.delete :first)
      type = expected.delete :type
      expect(first_ast.type).to eq type if type

      name = expected.delete :name
      expect(first_ast.name).to eq name if name

      expect(expected).to be_empty
    end

    # sanity
    expect(asrts).to be_empty
  end

  def get_terminals(ast)
    return ast if ast.terminal?
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

  context 'parsing' do
    example 'sanity test: some basic parsing' do
      parses! 'x', first: {name: 'x'}
    end

    example 'local vars are made of lowercase a-z and underscores' do
      parses! 'x',   first: { type: :local_variable, name: 'x' }
      parses! '_',   first: { type: :local_variable, name: '_' }
      parses! '_x_', first: { type: :local_variable, name: '_x_' }
      parses! 'a_b', first: { type: :local_variable, name: 'a_b' }
      parses! [*'a'..'z'].join, first: {
        type:  :local_variable,
        name: 'abcdefghijklmnopqrstuvwxyz',
      }
    end

    example 'ivars are identifiers with an @ prefix'
    example 'method calls are to the RHS of a "."'
    example 'lines beginning with method calls are invoked on the result of the previous line'
    example 'setters are method calls on the LHS of an assignment arrow'
  end

  context 'running', pending: true do
    context 'entry locations' do
      it 'can be anonymous functions' do
        e = eval '-> (x) x + x'
        expect(e.call 11).to eq 22
      end

      it 'can be named classes' do
        e = eval '-> :A ()'
        expect(e::A).to be_a_kind_of Class
      end
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
end
