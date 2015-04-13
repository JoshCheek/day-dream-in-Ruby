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
      generate ast, :toplevel, ''
    end

    private

    def generate(ast, entry, indentation)
      return '' unless ast
      case ast.type
      when :body
        body = generate ast.expressions, entry, indent(indentation)
        if wrap
          "Module.new {\n#{indent indentation}#{
            body
          }}\n#{indentation}"
        else
          body
        end

      when :expressions
        ast.expressions
          .map { |expr| "#{generate expr, entry, indentation}\n#{indentation}" }
          .join

      when :entry_location
        case [entry, ast.door.type]
        when [:toplevel, :block]
          "define_singleton_method(:call)#{generate ast.door, entry, indent(indentation)}"
        else
          raise "Unknown entry location: #{entry.inspect}"
        end

      when :binary_expression
        "((#{generate ast.left_child, entry, indentation}) #{ast.operator} (#{generate ast.right_child, entry, indentation}))"

      when :send_message
        "(#{generate ast.receiver, entry, indentation}).#{ast.name}(#{
            ast.arguments.map { |arg|
              generate arg, indentation
            }.join(', ')
            })#{' ' if ast.block}#{generate ast.block, entry, indentation}"

      when :block
        "{ |#{ast.param_names.join ', '}|\n#{indent(indentation)}#{
          generate ast.body, entry, indent(indentation)}\n#{indentation
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
