require 'ddir'

module SpecHelpers
  def parses!(body, assertions)
    ast! parse(body, errstream: $stderr), assertions
  end

  def parse(body, errstream: $stderr)
    Ddir.parse body: body, errstream: errstream
  end

  def ast!(ast, assertions)
    asrts = assertions.dup
    hash_assert ast.first, asrts.delete(:first)
    expect(asrts).to be_empty
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
  config.disable_monkey_patching!
end
