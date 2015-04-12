require 'treetop'
require 'pp'

def BuildTheParser(opts)
  BuildTheParser.new(opts).call
end

def Parse(opts)
  Parse.new(opts).parse
end

class BuildTheParser
  def initialize(grammar_file:, compile:)
    @grammar_file = grammar_file
    @parser_file  = "#@grammar_file.generated.rb"
    @compile      = compile
  end

  def call
    compile! if @compile
    load_file
  end

  private

  def compile!
    compiler = Treetop::Compiler::GrammarCompiler.new
    File.write @parser_file, compiler.ruby_source(@grammar_file)
  end

  def load_file
    definition = File.read(@parser_file)
    namespace  = Module.new
    namespace.class_eval definition, @parser_file
  end
end

class Parse
  def initialize(body:, parser_class:, pry: false, errstream:$stderr)
    self.pry          = pry
    self.body         = body
    self.errstream    = errstream
    self.parser_class = parser_class
  end

  def parse
    parser = parser_class.new
    result = parser.parse body
    return result if result
    result = parser.parse body, consume_all_input: false # more informative
    print_failure(body, result, parser)
    raise "Failed to parse!"
  ensure
    binding.pry if pry?
  end

  private

  attr_accessor :pry, :parser_class, :errstream, :body

  alias pry? pry

  def print_failure(body, result, parser)
    print_fail_pair :body                       , body
    print_fail_pair :terminal_failures          , parser.terminal_failures
    print_fail_pair :root                       , parser.root
    print_fail_pair :index                      , parser.index
    print_fail_pair :max_terminal_failure_index , parser.max_terminal_failure_index
    print_fail_pair :failure_column             , parser.failure_column
    print_fail_pair :failure_index              , parser.failure_index
    print_fail_pair :failure_line               , parser.failure_line
    print_fail_pair :failure_reason             , parser.failure_reason
    print_fail_pair :result                     , result
    print_fail_pair :input                      , parser.input
  end

  def print_fail_pair(key, value)
    val = value.inspect.gsub(/^/, '  ')
    whitespace = (val.lines.length == 1) ?
                   " " * (30 - key.length - 2) :
                   "\n"
    errstream.puts "\e[31m #{key} \e[39m#{whitespace}#{val}"
  end
end


class RubySyntax
  include Enumerable

  def children
    raise NotImplementedError, 'Override #children in subclasses'
  end

  def type
    @type ||= classname.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.intern
  end

  def each(&block)
    children.each(&block)
  end

  def inspect
    pretty_inspect
  end

  def pretty_print(pp)
    pp.text "#<#{classname}"
    pp.group 2 do
      pp.breakable '' # place inside so that if we break, we are indented
      last_child = children.last
      children.each do |child|
        # it can break with a comma/newline, after any child except after the last
        pp.pp child
        pp.comma_breakable unless child == last_child
      end
    end
    pp.breakable # can break after last child
    pp.text '>'
  end

  def classname
    @classname ||= self.class.to_s.split('::').last
  end


  class Body < RubySyntax
    attr_accessor :expressions

    def initialize(expressions)
      self.expressions = expressions # expressions node, not a collection
    end

    def children
      [expressions]
    end
  end


  class Expressions < RubySyntax
    attr_accessor :expressions

    def initialize(expressions)
      self.expressions = expressions
    end

    def children
      expressions
    end
  end


  class BinaryExpression < RubySyntax
    attr_accessor :left_child, :operator, :right_Child
    def initialize(left_child, operator, right_Child)
      self.left_child  = left_child
      self.operator    = operator
      self.right_Child = right_Child
    end

    def children
      [left_child, operator, right_Child]
    end
  end


  class Variable < RubySyntax
    attr_accessor :name
    def initialize(name)
      self.name = name
    end

    def children
      []
    end

    def pretty_print(pp)
      pp.text "#<#{classname} #{name.inspect}>"
    end
  end

  class LocalVariable < Variable
  end

  class InstanceVariable < Variable
  end
end
