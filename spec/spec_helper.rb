require 'stringio'
require 'ddir'

module SpecHelpers
  parser_class = Ddir.build_parser \
    grammar_file: File.expand_path('../lib/ddir/ddir.treetop', __dir__),
    compile:      true

  define_singleton_method(:parser_class) { parser_class }

  def parses!(body, assertions)
    ast! parse(body, errstream: $stderr), assertions
  end

  def parse(body, errstream: StringIO.new)
    Ddir.parse body:         body,
               parser_class: SpecHelpers.parser_class,
               errstream:    errstream
  end

  def ast!(ast, assertions)
    asrts = assertions.dup
    first = ast.expressions.first
    hash_assert first, asrts.delete(:first) # first
    expect(asrts).to be_empty # sanity
  end

  def get_terminals(ast)
    return ast if ast.terminal?
    ast.elements.flat_map { |child| get_terminals child }
  end

  def hash_assert(ast, expectations)
    (expectations || {}).each do |attr_name, expected|
      actual = ast.__send__ attr_name
      if expected.kind_of? Hash
        hash_assert actual, expected
      else
        expect(actual).to eq expected
      end
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end
