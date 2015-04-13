require 'pp'

module Ddir
  class Ast
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


    class Body < Ast
      attr_accessor :expressions

      def initialize(expressions)
        self.expressions = expressions # expressions node, not a collection
      end

      def children
        [expressions]
      end
    end


    class Expressions < Ast
      attr_accessor :expressions

      def initialize(expressions)
        self.expressions = expressions
      end

      def children
        expressions
      end
    end


    class EntryLocation < Ast
      attr_accessor :name, :body
      def initialize(name, body)
        self.name = name
        self.body = body
      end
      def children
        [name, body]
      end
      def via_class?
        !!(name =~ /^[A-Z]/)
      end
      def via_method?
        !via_class?
      end
    end


    class BinaryExpression < Ast
      attr_accessor :left_child, :operator, :right_child
      def initialize(left_child, operator, right_child)
        self.left_child  = left_child
        self.operator    = operator
        self.right_child = right_child
      end

      def children
        [left_child, operator, right_child]
      end
    end


    class Assignment < Ast
      attr_accessor :target, :value
      def initialize(target, value)
        self.target = target
        self.value  = value
      end
      def children
        [target, value]
      end
    end


    class SendMessage < Ast
      attr_accessor :receiver, :name, :arguments, :block

      def initialize(receiver, name, arguments, block)
        self.receiver  = receiver
        self.name      = name
        self.arguments = arguments
        self.block     = block
      end

      def children
        [receiver, '.', name, arguments]
      end
    end


    class Block < Ast
      attr_accessor :param_names, :body
      def initialize(param_names, body)
        self.param_names = param_names
        self.body        = body
      end

      def children
        [body]
      end
    end

    class ValueLiteral < Ast
      attr_accessor :value
      def initialize(value)
        self.value = value
      end
      def children
        [value]
      end
    end

    class Integer < ValueLiteral
    end


    class Symbol < ValueLiteral
    end


    class Self < Ast
      def children
        []
      end
    end

    class None < Ast
      def children
        []
      end
    end


    class Variable < Ast
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
end
