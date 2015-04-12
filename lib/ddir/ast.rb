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


    class BinaryExpression < Ast
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


    class Self < Ast
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

    class SendMessage < Ast
      attr_accessor :receiver, :name, :arguments, :block

      def initialize(receiver, name, arguments)
        self.receiver  = receiver
        self.name      = name
        self.arguments = arguments
        self.block     = nil
      end

      def children
        [receiver, '.', name, arguments]
      end
    end

    class LocalVariable < Variable
    end

    class InstanceVariable < Variable
    end
  end
end
