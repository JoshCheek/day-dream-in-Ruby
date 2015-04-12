require 'treetop/runtime'

module DayDreamInRuby
  include Treetop::Runtime

  def root
    @root ||= :body
  end

  module Body0
    def exprs
      elements[0]
    end
  end

  module Body1
    def to_ast
      Ddir::Ast::Body.new exprs.to_ast
    end
  end

  def _nt_body
    start_index = index
    if node_cache[:body].has_key?(index)
      cached = node_cache[:body][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_expressions
    s0 << r1
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Body0)
      r0.extend(Body1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:body][start_index] = r0

    r0
  end

  module Expressions0
    def sp1
      elements[0]
    end

    def expression
      elements[1]
    end

    def sp2
      elements[2]
    end

  end

  module Expressions1
    def to_ast
      if elements.size == 1
        elements.first.expression.to_ast
      else
        Ddir::Ast::Expressions.new \
          elements.map { |el| el.expression.to_ast }
      end
    end
  end

  def _nt_expressions
    start_index = index
    if node_cache[:expressions].has_key?(index)
      cached = node_cache[:expressions][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      i1, s1 = index, []
      r2 = _nt_sp
      s1 << r2
      if r2
        r3 = _nt_expression
        s1 << r3
        if r3
          r4 = _nt_sp
          s1 << r4
          if r4
            r6 = _nt_nl
            if r6
              r5 = r6
            else
              r5 = instantiate_node(SyntaxNode,input, index...index)
            end
            s1 << r5
          end
        end
      end
      if s1.last
        r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
        r1.extend(Expressions0)
      else
        @index = i1
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    r0.extend(Expressions1)

    node_cache[:expressions][start_index] = r0

    r0
  end

  module Expression0
    def head
      elements[0]
    end

    def tail
      elements[1]
    end
  end

  module Expression1
    def to_ast
      tail.elements.inject head.to_ast do |ast, modifier|
        modifier.to_ast ast
      end
    end
  end

  def _nt_expression
    start_index = index
    if node_cache[:expression].has_key?(index)
      cached = node_cache[:expression][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    i1 = index
    r2 = _nt_variable
    if r2
      r1 = r2
    else
      r3 = _nt_self
      if r3
        r1 = r3
      else
        @index = i1
        r1 = nil
      end
    end
    s0 << r1
    if r1
      s4, i4 = [], index
      loop do
        r5 = _nt_expression_modifiers
        if r5
          s4 << r5
        else
          break
        end
      end
      r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
      s0 << r4
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Expression0)
      r0.extend(Expression1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:expression][start_index] = r0

    r0
  end

  module ExpressionModifiers0
    def sp
      elements[0]
    end

    def modifier
      elements[1]
    end
  end

  module ExpressionModifiers1
    def modifier
      elements[0]
    end
  end

  module ExpressionModifiers2
    def to_ast(to_modify)
      modifier.to_ast to_modify
    end
  end

  def _nt_expression_modifiers
    start_index = index
    if node_cache[:expression_modifiers].has_key?(index)
      cached = node_cache[:expression_modifiers][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    i1, s1 = index, []
    r2 = _nt_sp
    s1 << r2
    if r2
      r3 = _nt_binary_op_call
      s1 << r3
    end
    if s1.last
      r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
      r1.extend(ExpressionModifiers0)
    else
      @index = i1
      r1 = nil
    end
    if r1
      r0 = r1
      r0.extend(ExpressionModifiers2)
    else
      i4, s4 = index, []
      r5 = _nt_send_message
      s4 << r5
      if s4.last
        r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
        r4.extend(ExpressionModifiers1)
      else
        @index = i4
        r4 = nil
      end
      if r4
        r0 = r4
        r0.extend(ExpressionModifiers2)
      else
        @index = i0
        r0 = nil
      end
    end

    node_cache[:expression_modifiers][start_index] = r0

    r0
  end

  module SendMessage0
    def method_name
      elements[1]
    end
  end

  module SendMessage1
    def to_ast(receiver)
      Ddir::Ast::SendMessage.new receiver, method_name.text_value.intern
    end
  end

  def _nt_send_message
    start_index = index
    if node_cache[:send_message].has_key?(index)
      cached = node_cache[:send_message][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?(".", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure(".")
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_identifier
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(SendMessage0)
      r0.extend(SendMessage1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:send_message][start_index] = r0

    r0
  end

  module BinaryOpCall0
    def operator
      elements[0]
    end

    def sp
      elements[1]
    end

    def rhs
      elements[2]
    end
  end

  module BinaryOpCall1
    def to_ast(lhs)
      Ddir::Ast::BinaryExpression.new lhs,
                                      operator.text_value,
                                      rhs.to_ast
    end
  end

  def _nt_binary_op_call
    start_index = index
    if node_cache[:binary_op_call].has_key?(index)
      cached = node_cache[:binary_op_call][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_operator
    s0 << r1
    if r1
      r2 = _nt_sp
      s0 << r2
      if r2
        r3 = _nt_expression
        s0 << r3
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(BinaryOpCall0)
      r0.extend(BinaryOpCall1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:binary_op_call][start_index] = r0

    r0
  end

  module Self0
    def to_ast
      Ddir::Ast::Self.new
    end
  end

  def _nt_self
    start_index = index
    if node_cache[:self].has_key?(index)
      cached = node_cache[:self][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    if has_terminal?("@", false, index)
      r0 = instantiate_node(SyntaxNode,input, index...(index + 1))
      r0.extend(Self0)
      @index += 1
    else
      terminal_parse_failure("@")
      r0 = nil
    end

    node_cache[:self][start_index] = r0

    r0
  end

  module Variable0
    def variable
      elements[0]
    end
  end

  module Variable1
    def to_ast
      variable.to_ast
    end
  end

  def _nt_variable
    start_index = index
    if node_cache[:variable].has_key?(index)
      cached = node_cache[:variable][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    i1 = index
    r2 = _nt_local_variable
    if r2
      r1 = r2
    else
      r3 = _nt_instance_variable
      if r3
        r1 = r3
      else
        @index = i1
        r1 = nil
      end
    end
    s0 << r1
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Variable0)
      r0.extend(Variable1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:variable][start_index] = r0

    r0
  end

  module LocalVariable0
    def to_ast
      Ddir::Ast::LocalVariable.new text_value.intern
    end
  end

  def _nt_local_variable
    start_index = index
    if node_cache[:local_variable].has_key?(index)
      cached = node_cache[:local_variable][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    r0 = _nt_identifier
    r0.extend(LocalVariable0)

    node_cache[:local_variable][start_index] = r0

    r0
  end

  module InstanceVariable0
    def identifier
      elements[1]
    end
  end

  module InstanceVariable1
    def to_ast
      Ddir::Ast::InstanceVariable.new text_value.intern
    end
  end

  def _nt_instance_variable
    start_index = index
    if node_cache[:instance_variable].has_key?(index)
      cached = node_cache[:instance_variable][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?("@", false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure("@")
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_identifier
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(InstanceVariable0)
      r0.extend(InstanceVariable1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:instance_variable][start_index] = r0

    r0
  end

  def _nt_identifier
    start_index = index
    if node_cache[:identifier].has_key?(index)
      cached = node_cache[:identifier][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[_a-z]', true, index)
        r1 = true
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    end

    node_cache[:identifier][start_index] = r0

    r0
  end

  def _nt_operator
    start_index = index
    if node_cache[:operator].has_key?(index)
      cached = node_cache[:operator][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    if has_terminal?('+', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('+')
      r1 = nil
    end
    if r1
      r0 = r1
    else
      if has_terminal?('-', false, index)
        r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure('-')
        r2 = nil
      end
      if r2
        r0 = r2
      else
        @index = i0
        r0 = nil
      end
    end

    node_cache[:operator][start_index] = r0

    r0
  end

  def _nt_sp
    start_index = index
    if node_cache[:sp].has_key?(index)
      cached = node_cache[:sp][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?(' ', false, index)
        r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure(' ')
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:sp][start_index] = r0

    r0
  end

  def _nt_nl
    start_index = index
    if node_cache[:nl].has_key?(index)
      cached = node_cache[:nl][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    if has_terminal?("\n", false, index)
      r0 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure("\n")
      r0 = nil
    end

    node_cache[:nl][start_index] = r0

    r0
  end

end

class DayDreamInRubyParser < Treetop::Runtime::CompiledParser
  include DayDreamInRuby
end

