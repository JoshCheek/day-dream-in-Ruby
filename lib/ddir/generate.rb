module Ddir
  def self.generate(ast, wrap:true)
    Generate.new(ast: ast, wrap: wrap).call
  end

  class Generate
    attr_accessor :wrap, :ast

    def initialize(ast:, wrap:)
      self.ast  = ast
      self.wrap = wrap
    end

    def call
      generate ast, ''
    end

    private

    def generate(ast, indentation)
      return '' unless ast
      case ast.type
      when :body
        body = generate ast.expressions, indent(indentation)
        if wrap
          "Module.new {\n#{indent indentation}#{
            body
          }}\n#{indentation}"
        else
          body
        end

      when :expressions
        ast.expressions
          .map { |expr| "#{generate expr, indentation}\n#{indentation}" }
          .join

      when :binary_expression
        "((#{generate ast.left_child, indentation}) #{ast.operator} (#{generate ast.right_child, indentation}))"

      when :send_message
        "(#{generate ast.receiver, indentation}).#{ast.name}(#{
            ast.arguments.map { |arg|
              generate arg, indentation
            }.join(', ')
            })#{' ' if ast.block}#{generate ast.block, indentation}"

      when :block
        "{ |#{ast.param_names.join ', '}|\n#{indent(indentation)}#{
          generate ast.body, indent(indentation)}\n#{indentation
        }}\n#{indentation}"

      when :integer
        ast.value.to_s

      when :self
        'self'

      when :local_variable, :instance_variable
        ast.name.to_s

      else
        raise "CANNOT GENERATE #{ast.inspect}"
      end
    end

    def indent(indentation)
      '  ' + indentation
    end
  end
end
