module Ddir
  def self.parse(opts)
    Parse.new(opts).parse.to_ast
  end

  # locate relevant files, check their times
  grammar_filename = File.expand_path 'ddir.treetop', __dir__
  parser_filename  = File.expand_path 'ddir.treetop.generated.rb', __dir__
  grammer_changed  = File.mtime grammar_filename
  parser_generated = File.mtime parser_filename

  # recompile the parser if it is out of date
  if parser_generated < grammer_changed
    require 'treetop'
    File.write(
      parser_filename,
      Treetop::Compiler::GrammarCompiler.new.ruby_source(grammar_filename)
    )
  end

  # load the parser to a constnat we choose
  TreetopParser = Module.new.module_eval(
    File.read(parser_filename),
    parser_filename
  )

  class Parse
    def initialize(body:, errstream:$stderr)
      self.body         = body
      self.errstream    = errstream
    end

    def parse
      parser = TreetopParser.new
      result = parser.parse body
      return result if result
      result = parser.parse body, consume_all_input: false # more informative
      print_failure(body, result, parser)
      raise "Failed to parse!"
    end

    private

    attr_accessor :errstream, :body

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
      inspected_value = value.inspect.gsub(/^/, '  ')
      whitespace = if inspected_value.lines.length == 1
        " " * (30 - key.length - 2)
      else
        "\n"
      end
      errstream.puts "\e[31m #{key} \e[39m#{whitespace}#{inspected_value}"
    end
  end
end
