module Ddir
  def self.generate(ast)
    Generate.new(ast).call
  end

  class Generate
    attr_accessor :ast
    def initialize(ast)
      self.ast       = ast
    end

    def call
      generate ast, ''
    end

    private

    def generate(ast, indentation)
      case ast
      when NilClass
        # noop
      when Ast::Body
        "Module.new {#{indentation}\n#{
          generate ast.expressions, indent(indentation)
        }\n#{indentation}}\n#{indentation}"
      when Ast::Expressions
        ast.expressions
          .map { |expr| "#{indentation}#{generate expr, indentation};" }
          .join
      when Ast::BinaryExpression
        "((#{generate ast.left_child, indentation}) #{ast.operator} (#{generate ast.right_child, indentation}))"
      when Ast::SendMessage
        "(#{generate ast.receiver, indentation}).#{ast.name}(#{
            ast.arguments.map { |arg|
              generate arg, indentation
            }.join(', ')
            }) #{generate ast.block, indentation}"
      when Ast::Block
        "{ |#{ast.param_names.join ', '}|\n#{indent(indentation)}#{
          generate ast.body, indent(indentation)}\n#{indentation
        }}\n#{indentation}"
      when Ast::Integer
        ast.value.to_s
      when Ast::Self
        'self'
      when Ast::LocalVariable
        ast.name.to_s
      when Ast::InstanceVariable
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
