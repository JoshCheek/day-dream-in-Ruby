require 'pp'

module Ddir
  class Ast

    class Context
      attr_reader :depth

      def initialize
        @depth             = 0
        @expressions_stack = []
        @locals_stack      = [[]]
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

      def declare_local(local)
        @locals_stack.last << local
        local
      end

      def record_locals
        @locals_stack.push []
        yield
        @locals_stack.pop
      end
    end


    def type
      @type ||= classname.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.intern
    end

    def classname
      @classname ||= self.class.to_s.split('::').last
    end

    Self = Class.new Ast

    class Body < Ast
      attr_accessor :expressions

      def initialize(expressions:)
        self.expressions = expressions # expressions node, not a collection
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
      include Enumerable

      attr_accessor :expressions, :depth

      def initialize(depth:, expressions:[])
        self.expressions = expressions
        self.depth       = depth
      end

      alias children expressions

      def each(&block)
        expressions.each(&block)
      end

      def length
        expressions.length
      end

      def add_child(child)
        expressions << child
        child
      end

      def modify_child(&block)
        expressions.push block.call expressions.pop
      end

      def child_at(depth)
        return self if self.depth == depth
        expressions.last.child_at(depth)
      end
    end


    class EntryLocation < Ast
      attr_accessor :name, :body, :depth
      def initialize(name:, body:, depth:)
        self.name  = name
        self.body  = body
        self.depth = depth
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
      def initialize(left_child:, operator:, right_child:)
        self.left_child  = left_child
        self.operator    = operator
        self.right_child = right_child
      end
    end


    class Assignment < Ast
      attr_accessor :target, :value
      def initialize(target:, value:)
        self.target = target
        self.value  = value
      end
    end


    class SendMessage < Ast
      attr_accessor :receiver, :name, :arguments, :block, :depth

      def initialize(receiver:, name:, arguments:, block:, depth:)
        self.receiver  = receiver
        self.name      = name
        self.arguments = arguments
        self.block     = block
        self.depth     = depth
      end

      def child_at(depth)
        self.block ||= Block.new(depth: self.depth)
        block.child_at(depth)
      end
    end


    class Block < Ast
      attr_accessor :params, :body, :depth
      def initialize(params:[], body:nil, depth:)
        self.params = params
        self.body   = body
        self.depth  = depth
      end

      def params?
        params.any?
      end

      def child_at(depth)
        self.body ||= Expressions.new depth: self.depth+1
        body.child_at(depth)
      end
    end


    class Params < Ast
      include Enumerable

      attr_accessor :params
      def initialize(params:)
        self.params = params
      end

      def each(&block)
        params.each(&block)
      end
    end
    DestructuredParam = Class.new Params


    class Param < Ast
      attr_accessor :name
      def initialize(name:)
        self.name = name
      end
    end
    class DefaultParam < Param
      attr_accessor :value
      def initialize(value:, **rest)
        self.value = value
        super rest
      end
    end
    OrdinalParam  = Class.new Param
    RequiredParam = Class.new Param


    class ValueLiteral < Ast
      attr_accessor :value
      def initialize(value:)
        self.value = value
      end
    end
    Integer = Class.new ValueLiteral
    Symbol  = Class.new ValueLiteral
    String  = Class.new ValueLiteral


    class Variable < Ast
      attr_accessor :name
      def initialize(name:)
        self.name = name
      end
    end
    LocalVariable    = Class.new Variable
    InstanceVariable = Class.new Variable
  end
end
