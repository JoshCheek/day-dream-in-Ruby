require 'pp'

module Ddir
  class Ast

    class Context
      attr_reader :depth
      def initialize
        @depth = 0
        @expression_stack = []
      end
      def push_expressions
        exprs = Expressions.new depth: depth
        @expression_stack.push exprs
        yield
        @expression_stack.pop while @expression_stack.include? exprs
        exprs
      end
      def update_depth(new_depth)
        @depth = new_depth
        @expression_stack.pop while depth < current_expression.depth
      end
      def current_expression
        @expression_stack.last
      end
    end


    include Enumerable

    attr_accessor :depth, :parent

    def initialize(depth:0, parent:nil)
      self.depth  = depth
      self.parent = parent
    end

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


    class Null < Ast
      def initialize(**rest)
        super({parent: self}.merge(rest))
      end
      def children
        []
      end
    end


    class Body < Ast
      attr_accessor :expressions

      def initialize(expressions:nil, **rest)
        super rest
        expressions ||= Ast::Null.new(parent: self, depth: depth)
        self.expressions = expressions # expressions node, not a collection
      end

      def children
        [expressions]
      end
    end


    class Expressions < Ast
      attr_accessor :expressions

      def initialize(expressions:[], **rest)
        self.expressions = expressions
        super rest
      end

      def children
        expressions
      end
    end


    class EntryLocation < Ast
      attr_accessor :name, :body
      def initialize(name:, body:nil, **rest)
        self.name = name
        self.body = body
        body.parent = self if body
        super rest
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
      def initialize(left_child:nil, operator:, right_child:nil, **rest)
        self.left_child    = left_child
        self.operator      = operator
        self.right_child   = right_child
        left_child.parent  = self if left_child
        right_child.parent = self if right_child
        super rest
      end

      def children
        [left_child, operator, right_child]
      end
    end


    class Assignment < Ast
      attr_accessor :target, :value
      def initialize(value:, **rest)
        self.value   = value
        value.parent = self
        super rest
      end
      def children
        [target, value]
      end
    end


    class SendMessage < Ast
      attr_accessor :receiver, :name, :arguments, :block

      def initialize(receiver:nil, name:, arguments:[], block:nil, **rest)
        self.receiver   = receiver
        self.name       = name
        self.arguments  = arguments
        self.block      = block
        block.parent    = self if block
        receiver.parent = self if receiver
        arguments.each { |arg| arg.parent = self }
        super rest
      end

      def children
        [receiver, '.', name, arguments, block]
      end
    end


    class Block < Ast
      attr_accessor :param_names, :body
      def initialize(param_names:, body:, **rest)
        super rest
        self.param_names = param_names
        self.body        = body
        body.parent      = self
        super rest
      end

      def children
        [body]
      end
    end


    class ValueLiteral < Ast
      attr_accessor :value
      def initialize(value, **rest)
        self.value = value
        super rest
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

      def initialize(name:, **rest)
        self.name = name
        super rest
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
