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
    def expression
      elements[1]
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
      r3 = _nt_sp
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s1 << r2
      if r2
        r4 = _nt_expression
        s1 << r4
        if r4
          r6 = _nt_sp
          if r6
            r5 = r6
          else
            r5 = instantiate_node(SyntaxNode,input, index...index)
          end
          s1 << r5
          if r5
            r8 = _nt_nl
            if r8
              r7 = r8
            else
              r7 = instantiate_node(SyntaxNode,input, index...index)
            end
            s1 << r7
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
    r2 = _nt_entry_location
    if r2
      r1 = r2
    else
      r3 = _nt_variable
      if r3
        r1 = r3
      else
        r4 = _nt_self
        if r4
          r1 = r4
        else
          r5 = _nt_integer
          if r5
            r1 = r5
          else
            r6 = _nt_symbol
            if r6
              r1 = r6
            else
              @index = i1
              r1 = nil
            end
          end
        end
      end
    end
    s0 << r1
    if r1
      s7, i7 = [], index
      loop do
        r8 = _nt_expression_modifiers
        if r8
          s7 << r8
        else
          break
        end
      end
      r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
      s0 << r7
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
    def modifier
      elements[0]
    end
  end

  module ExpressionModifiers3
    def modifier
      elements[1]
    end
  end

  module ExpressionModifiers4
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
    r3 = _nt_sp
    if r3
      r2 = r3
    else
      r2 = instantiate_node(SyntaxNode,input, index...index)
    end
    s1 << r2
    if r2
      r4 = _nt_binary_op_call
      s1 << r4
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
      r0.extend(ExpressionModifiers4)
    else
      i5, s5 = index, []
      r6 = _nt_send_assignemnt_message
      s5 << r6
      if s5.last
        r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
        r5.extend(ExpressionModifiers1)
      else
        @index = i5
        r5 = nil
      end
      if r5
        r0 = r5
        r0.extend(ExpressionModifiers4)
      else
        i7, s7 = index, []
        r8 = _nt_send_message
        s7 << r8
        if s7.last
          r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
          r7.extend(ExpressionModifiers2)
        else
          @index = i7
          r7 = nil
        end
        if r7
          r0 = r7
          r0.extend(ExpressionModifiers4)
        else
          i9, s9 = index, []
          r11 = _nt_sp
          if r11
            r10 = r11
          else
            r10 = instantiate_node(SyntaxNode,input, index...index)
          end
          s9 << r10
          if r10
            r12 = _nt_assignment
            s9 << r12
          end
          if s9.last
            r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
            r9.extend(ExpressionModifiers3)
          else
            @index = i9
            r9 = nil
          end
          if r9
            r0 = r9
            r0.extend(ExpressionModifiers4)
          else
            @index = i0
            r0 = nil
          end
        end
      end
    end

    node_cache[:expression_modifiers][start_index] = r0

    r0
  end

  module Assignment0
    def value
      elements[2]
    end
  end

  module Assignment1
    def to_ast(target_ast)
      Ddir::Ast::Assignment.new target_ast, value.to_ast
    end
  end

  def _nt_assignment
    start_index = index
    if node_cache[:assignment].has_key?(index)
      cached = node_cache[:assignment][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('<-', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 2))
      @index += 2
    else
      terminal_parse_failure('<-')
      r1 = nil
    end
    s0 << r1
    if r1
      r3 = _nt_sp
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_expression
        s0 << r4
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Assignment0)
      r0.extend(Assignment1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:assignment][start_index] = r0

    r0
  end

  module SendAssignemntMessage0
    def name
      elements[1]
    end

    def assignment
      elements[3]
    end
  end

  module SendAssignemntMessage1
    def to_ast(receiver_ast)
      Ddir::Ast::SendMessage.new \
        receiver_ast,
        :"#{name.text_value}=",
        [assignment.value.to_ast], # args
        nil                        # no block
    end
  end

  def _nt_send_assignemnt_message
    start_index = index
    if node_cache[:send_assignemnt_message].has_key?(index)
      cached = node_cache[:send_assignemnt_message][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('.', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('.')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_identifier
      s0 << r2
      if r2
        r4 = _nt_sp
        if r4
          r3 = r4
        else
          r3 = instantiate_node(SyntaxNode,input, index...index)
        end
        s0 << r3
        if r3
          r5 = _nt_assignment
          s0 << r5
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(SendAssignemntMessage0)
      r0.extend(SendAssignemntMessage1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:send_assignemnt_message][start_index] = r0

    r0
  end

  module SendMessage0
    def sp
      elements[0]
    end

    def expression
      elements[1]
    end
  end

  module SendMessage1
    def name
      elements[1]
    end

    def args
      elements[2]
    end

    def maybe_block
      elements[4]
    end
  end

  module SendMessage2
    def to_ast(receiver_ast)
      Ddir::Ast::SendMessage.new \
        receiver_ast,
        name.text_value.intern,
        args.elements.map { |arg| arg.expression.to_ast },
        (maybe_block.to_ast unless maybe_block.empty?)
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
      if r2
        s3, i3 = [], index
        loop do
          i4, s4 = index, []
          r5 = _nt_sp
          s4 << r5
          if r5
            r6 = _nt_expression
            s4 << r6
          end
          if s4.last
            r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
            r4.extend(SendMessage0)
          else
            @index = i4
            r4 = nil
          end
          if r4
            s3 << r4
          else
            break
          end
        end
        r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
        s0 << r3
        if r3
          r8 = _nt_sp
          if r8
            r7 = r8
          else
            r7 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r7
          if r7
            r10 = _nt_block
            if r10
              r9 = r10
            else
              r9 = instantiate_node(SyntaxNode,input, index...index)
            end
            s0 << r9
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(SendMessage1)
      r0.extend(SendMessage2)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:send_message][start_index] = r0

    r0
  end

  module Block0
    def params
      elements[1]
    end

    def body
      elements[4]
    end
  end

  module Block1
    def to_ast
      body_ast = body.empty? ? Ddir::Ast::None.new : body.to_ast
      Ddir::Ast::Block.new params.ordered_names,
                           body_ast
    end
  end

  def _nt_block
    start_index = index
    if node_cache[:block].has_key?(index)
      cached = node_cache[:block][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('(', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('(')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_params
      s0 << r2
      if r2
        if has_terminal?(')', false, index)
          r3 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure(')')
          r3 = nil
        end
        s0 << r3
        if r3
          r5 = _nt_sp
          if r5
            r4 = r5
          else
            r4 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r4
          if r4
            r7 = _nt_expression
            if r7
              r6 = r7
            else
              r6 = instantiate_node(SyntaxNode,input, index...index)
            end
            s0 << r6
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Block0)
      r0.extend(Block1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:block][start_index] = r0

    r0
  end

  module Params0
    def local_variable
      elements[3]
    end
  end

  module Params1
    def first_name
      elements[0]
    end

    def remaining_names
      elements[1]
    end
  end

  module Params2
    def ordered_names
      names = []
      names << first_name.text_value.intern unless first_name.empty?
      remaining_names.elements.each { |n| names << n.local_variable.text_value.intern }
      names
    end
  end

  def _nt_params
    start_index = index
    if node_cache[:params].has_key?(index)
      cached = node_cache[:params][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r2 = _nt_local_variable
    if r2
      r1 = r2
    else
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      s3, i3 = [], index
      loop do
        i4, s4 = index, []
        r6 = _nt_sp
        if r6
          r5 = r6
        else
          r5 = instantiate_node(SyntaxNode,input, index...index)
        end
        s4 << r5
        if r5
          if has_terminal?(',', false, index)
            r7 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(',')
            r7 = nil
          end
          s4 << r7
          if r7
            r9 = _nt_sp
            if r9
              r8 = r9
            else
              r8 = instantiate_node(SyntaxNode,input, index...index)
            end
            s4 << r8
            if r8
              r10 = _nt_local_variable
              s4 << r10
            end
          end
        end
        if s4.last
          r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
          r4.extend(Params0)
        else
          @index = i4
          r4 = nil
        end
        if r4
          s3 << r4
        else
          break
        end
      end
      r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
      s0 << r3
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Params1)
      r0.extend(Params2)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:params][start_index] = r0

    r0
  end

  module EntryLocation0
    def name
      elements[2]
    end

    def body
      elements[4]
    end
  end

  module EntryLocation1
    def to_ast
      name_symbol = name.empty? ? :call : name.to_ast.value
      Ddir::Ast::EntryLocation.new name_symbol, body.to_ast
    end
  end

  def _nt_entry_location
    start_index = index
    if node_cache[:entry_location].has_key?(index)
      cached = node_cache[:entry_location][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?('->', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 2))
      @index += 2
    else
      terminal_parse_failure('->')
      r1 = nil
    end
    s0 << r1
    if r1
      r3 = _nt_sp
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r2
      if r2
        r5 = _nt_symbol
        if r5
          r4 = r5
        else
          r4 = instantiate_node(SyntaxNode,input, index...index)
        end
        s0 << r4
        if r4
          r7 = _nt_sp
          if r7
            r6 = r7
          else
            r6 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r6
          if r6
            r8 = _nt_block
            s0 << r8
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(EntryLocation0)
      r0.extend(EntryLocation1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:entry_location][start_index] = r0

    r0
  end

  module BinaryOpCall0
    def operator
      elements[0]
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
      r3 = _nt_sp
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_expression
        s0 << r4
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

  module Identifier0
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

    i0, s0 = index, []
    if has_terminal?('\G[_a-z]', true, index)
      r1 = true
      @index += 1
    else
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[_a-zA-Z0-9]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Identifier0)
    else
      @index = i0
      r0 = nil
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
    if s0.empty?
      @index = i0
      r0 = nil
    else
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    end

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

  module Integer0
    def to_ast
      Ddir::Ast::Integer.new text_value.to_i
    end
  end

  def _nt_integer
    start_index = index
    if node_cache[:integer].has_key?(index)
      cached = node_cache[:integer][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    s0, i0 = [], index
    loop do
      if has_terminal?('\G[0-9]', true, index)
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
      r0.extend(Integer0)
    end

    node_cache[:integer][start_index] = r0

    r0
  end

  module Symbol0
    def value
      elements[1]
    end
  end

  module Symbol1
    def to_ast
      Ddir::Ast::Symbol.new value.text_value.intern
    end
  end

  def _nt_symbol
    start_index = index
    if node_cache[:symbol].has_key?(index)
      cached = node_cache[:symbol][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    if has_terminal?(':', false, index)
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure(':')
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if has_terminal?('\G[_a-zA-Z0-9]', true, index)
          r3 = true
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        @index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Symbol0)
      r0.extend(Symbol1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:symbol][start_index] = r0

    r0
  end

end

class DayDreamInRubyParser < Treetop::Runtime::CompiledParser
  include DayDreamInRuby
end

