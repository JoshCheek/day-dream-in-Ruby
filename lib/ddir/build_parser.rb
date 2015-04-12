require 'treetop'

module Ddir
  def self.build_parser(opts)
    BuildTheParser.new(opts).call
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
end
