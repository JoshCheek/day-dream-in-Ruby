require 'ddir'

module SpecHelpers
  def parses!(body, assertions)
    ast! parse(body, errstream: $stderr), assertions
  end

  def parse(body, errstream: $stderr)
    Ddir.parse body: body, errstream: errstream
  end

  def eval(body, wrap:false)
    super Ddir.generate(parse(body), wrap: wrap)
  end

  def ast!(ast, positional_assertions)
    positional_assertions = if positional_assertions.kind_of? Array
      positional_assertions
    else
      [positional_assertions]
    end

    positional_assertions.each_with_index do |assertions, index|
      recursive_assert ast.children[index], assertions
    end
  end

  def get_terminals(ast)
    return ast if ast.terminal?
    ast.elements.flat_map { |child| get_terminals child }
  end

  def recursive_assert(ast, expectations)
    (expectations || {}).each do |attr_name, expected|
      actual = ast.__send__ attr_name
      case expected
      when Hash
        recursive_assert actual, expected
      when Array
        if actual == expected
          expect(actual).to eq expected
        else
          actual.zip(expected) { |actual_at_index, expected_at_index|
            recursive_assert actual_at_index, expected_at_index
          }
          expect(actual.count).to eq expected.count
        end
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
