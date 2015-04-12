require 'treetop'

class BuildTheParser
  def initialize(grammar_file:, compile:)
    @grammar_file = grammar_file
    @parser_file  = "#@grammar_file.generated.rb"
    @compile      = compile
  end

  def parser_class
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

def Parse(opts)
  Parse.new(opts).parse
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
