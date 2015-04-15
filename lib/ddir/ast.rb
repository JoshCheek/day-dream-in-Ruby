require 'pp'

module Ddir
  class Ast

    class Context
      attr_reader :depth

      def initialize
        @depth = 0
        @expressions_stack = []
      end

      def push_expressions
        exprs = Expressions.new depth: depth
        @expressions_stack.push exprs
        yield
        @expressions_stack.pop while @expressions_stack.include? exprs
        exprs
      end

      def current_expressions
        @expressions_stack.last
      end

      def add_child(depth, child)
        update_depth depth
        exprs_at(depth).add_child child
      end

      def modify(depth, &block)
        update_depth depth
        exprs_at(depth-1).modify_child(&block)
      end

      def exprs_at(depth)
        current_expressions.child_at depth
      end

      def update_depth(new_depth)
        @depth = new_depth
        @expressions_stack.pop while depth < current_expressions.depth
      end
    end


    include Enumerable

    def initialize(attrs={})
      return if attrs.empty?
      raise "Additional attrs! #{attrs.inspect} for #{self.class.inspect}"
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
      def children
        []
      end
    end


    class Body < Ast
      attr_accessor :expressions

      def initialize(expressions:, **rest)
        self.expressions = expressions # expressions node, not a collection
        super rest
      end

      def children
        if expressions.length == 1
          expressions.children
        else
          [expressions]
        end
      end
    end


    class Expressions < Ast
      attr_accessor :expressions, :depth

      def initialize(depth:, expressions:[], **rest)
        self.expressions = expressions
        self.depth       = depth
        super rest
      end

      def length
        expressions.length
      end

      def children
        expressions
      end

      def add_child(child)
        children << child
        child
      end

      def modify_child(&block)
        children.push block.call children.pop
      end

      def child_at(depth)
        return self if self.depth == depth
        expressions.last.child_at(depth)
      end
    end


    class EntryLocation < Ast
      attr_accessor :name, :body, :depth
      def initialize(name:, body:, depth:, **rest)
        self.name  = name
        self.body  = body
        self.depth = depth
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
      def child_at(depth)
        self.body ||= Block.new(depth: self.depth)
        body.child_at(depth)
      end
    end


    class BinaryExpression < Ast
      attr_accessor :left_child, :operator, :right_child
      def initialize(left_child:, operator:, right_child:, **rest)
        self.left_child  = left_child
        self.operator    = operator
        self.right_child = right_child
        super rest
      end

      def children
        [left_child, operator, right_child]
      end
    end


    class Assignment < Ast
      attr_accessor :target, :value
      def initialize(target:, value:, **rest)
        self.target = target
        self.value  = value
        super rest
      end
      def children
        [target, value]
      end
    end


    class SendMessage < Ast
      attr_accessor :receiver, :name, :arguments, :block, :depth

      def initialize(receiver:, name:, arguments:, block:, depth:, **rest)
        self.receiver  = receiver
        self.name      = name
        self.arguments = arguments
        self.block     = block
        self.depth     = depth
        super rest
      end

      def children
        [receiver, '.', name, arguments, block]
      end

      def child_at(depth)
        self.block ||= Block.new(depth: self.depth)
        block.child_at(depth)
      end
    end


    class Block < Ast
      attr_accessor :params, :body, :depth
      def initialize(params:[], body:nil, depth:, **rest)
        self.params = params
        self.body   = body
        self.depth  = depth
        super rest
      end

      def params?
        params.any?
      end

      def children
        [body]
      end

      def child_at(depth)
        self.body ||= Expressions.new depth: self.depth+1
        body.child_at(depth)
      end
    end


    class Params < Ast
      attr_accessor :params
      def initialize(params:, **rest)
        self.params = params
        super rest
      end

      def children
        params
      end
    end


    class Param < Ast
      attr_accessor :name
      def initialize(name:, **rest)
        self.name = name
        super rest
      end
      def children
        []
      end
    end

    class DefaultParam < Param
      attr_accessor :value
      def initialize(value:, **rest)
        self.value = value
        super rest
      end
    end

    class OrdinalParam < Param
    end

    class RequiredParam < Param
    end


    class ValueLiteral < Ast
      attr_accessor :value
      def initialize(value:, **rest)
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


    class String < ValueLiteral
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
