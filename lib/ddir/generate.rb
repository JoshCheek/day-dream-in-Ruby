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
          .map { |expr| generate expr, entry, indentation }
          .join "\n#{indentation}"

      when :entry_location
        if entry == :toplevel && ast.via_method?
          body = generate ast.body, :method, indentation
          "define_singleton_method(#{ast.name.inspect})#{body}"
        elsif entry == :toplevel && ast.via_class?
          body = generate ast.body, :class, indent(indentation)
          "const_set(#{ast.name.inspect}, Class.new #{body})"
        elsif entry == :class && ast.via_method?
          body = generate ast.body, :method, indentation
          "define_method(#{ast.name.inspect})#{body}"
        else
          raise "Unknown entry location: #{entry.inspect}"
        end

      when :binary_expression
        "((#{generate ast.left_child, entry, indentation}) #{ast.operator} (#{generate ast.right_child, entry, indentation}))"

      when :send_message
        receiver = if ast.receiver.type == :self && ast.name.to_s.end_with?('=')
          'self.'
        elsif ast.receiver.type == :self
          ""
        else
          "(#{generate ast.receiver, entry, indentation})."
        end
        "#{receiver}#{ast.name}(#{
            ast.arguments.map { |arg|
              generate arg, entry, indentation
            }.join(', ')
            })#{generate ast.block, entry, indentation}"

      when :block
        params = ""
        params = "|#{generate ast.params, entry, indentation}|" if ast.params?
        " { #{params}\n#{indent(indentation)}#{
          generate ast.body, entry, indent(indentation)}\n#{indentation
        }}\n#{indentation}"

      when :assignment
        "#{generate ast.target, entry, indentation} = #{
           generate ast.value,  entry, indentation}"

      when :integer
        ast.value.to_s

      when :self
        'self'

      when :symbol
        ":#{ast.value}"

      when :string
        ast.value.inspect

      when :local_variable, :instance_variable
        ast.name.to_s

      when :params, :destructured_param
        params = ast.map { |param| generate param, entry, indentation }
                    .join(', ')
        params = "(#{params})" if ast.type == :destructured_param
        params

      when :default_param
        "#{ast.name}:#{generate ast.value, entry, indentation}"

      when :ordinal_param
        ast.name.to_s

      when :required_param
        "#{ast.name}:"

      when :none
        ''

      else
        raise "CANNOT GENERATE #{ast.inspect}"
      end
    end

    def indent(indentation)
      '  ' + indentation
    end
  end
end
