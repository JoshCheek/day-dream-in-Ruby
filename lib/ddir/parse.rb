module Ddir
  def self.parse(opts)
    Parse.new(opts).parse.to_ast
  end

  class Parse
    def initialize(body:, parser_class:, errstream:$stderr)
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
    end

    private

    attr_accessor :parser_class, :errstream, :body

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
end
