require 'stringio'
require_relative 'helpers'

parser_class = BuildTheParser.new(
  grammar_file: 'whatevz.treetop',
  compile:      true,
).parser_class


RSpec.configure do |config|

  config.before { @parser_class = parser_class }

  config.include Module.new {
    def parses!(body, assertions)
      ast! parse(body), assertions
    end

    def parse(body)
      Parse body:         body,
            parser_class: @parser_class,
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
  }
end

RSpec.describe 'My language' do
  it 'parses expressions' do
    parses! 'x', terminals_include: 'x'
  end
end
