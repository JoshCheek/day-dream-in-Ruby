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
    def to_ast(context)
      Ddir::Ast::Body.new expressions: exprs.to_ast(context)
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
      elements[0]
    end

  end

  module Expressions1
    def declare_ast(context, depth)
      context.update_depth depth
      context.add_child depth, expression.to_ast(context)
    end
  end

  module Expressions2
    def modifiers
      elements[0]
    end

  end

  module Expressions3
    def declare_ast(context, depth)
      modifiers.elements.each do |modifier|
        context.modify depth do |ast|
          modifier.to_ast context, ast
        end
      end
    end
  end

  module Expressions4
    def declare_ast(context, depth)
      # noop (allows empty lines)
    end
  end

  module Expressions5
  end

  module Expressions6
    def declare_ast(context, depth)
      # ideally we would push these through,
      # but that would make generation hard,
      # and this project is mostly just a thought experiment
    end
  end

  module Expressions7
    def indentation
      elements[0]
    end

    def matched
      elements[1]
    end

  end

  module Expressions8
    def to_ast(context)
      context.push_expressions do
        elements.each { |el|
          # p el.indentation.depth => el.text_value
          # if the indentation increased
          # then it is a child of the last element, which is expected to be a block
          el.matched.declare_ast context, el.indentation.depth
        }
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
      r2 = _nt_indentation
      s1 << r2
      if r2
        i3 = index
        i4, s4 = index, []
        r5 = _nt_expression
        s4 << r5
        if r5
          r7 = _nt_sp
          if r7
            r6 = r7
          else
            r6 = instantiate_node(SyntaxNode,input, index...index)
          end
          s4 << r6
        end
        if s4.last
          r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
          r4.extend(Expressions0)
          r4.extend(Expressions1)
        else
          @index = i4
          r4 = nil
        end
        if r4
          r3 = r4
        else
          i8, s8 = index, []
          s9, i9 = [], index
          loop do
            r10 = _nt_expression_modifier
            if r10
              s9 << r10
            else
              break
            end
          end
          if s9.empty?
            @index = i9
            r9 = nil
          else
            r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
          end
          s8 << r9
          if r9
            r12 = _nt_sp
            if r12
              r11 = r12
            else
              r11 = instantiate_node(SyntaxNode,input, index...index)
            end
            s8 << r11
          end
          if s8.last
            r8 = instantiate_node(SyntaxNode,input, i8...index, s8)
            r8.extend(Expressions2)
            r8.extend(Expressions3)
          else
            @index = i8
            r8 = nil
          end
          if r8
            r3 = r8
          else
            r13 = _nt_nl
            r13.extend(Expressions4)
            if r13
              r3 = r13
            else
              i14, s14 = index, []
              if has_terminal?('#', false, index)
                r15 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure('#')
                r15 = nil
              end
              s14 << r15
              if r15
                s16, i16 = [], index
                loop do
                  if has_terminal?('\G[^\\n]', true, index)
                    r17 = true
                    @index += 1
                  else
                    r17 = nil
                  end
                  if r17
                    s16 << r17
                  else
                    break
                  end
                end
                r16 = instantiate_node(SyntaxNode,input, i16...index, s16)
                s14 << r16
                if r16
                  r19 = _nt_sp
                  if r19
                    r18 = r19
                  else
                    r18 = instantiate_node(SyntaxNode,input, index...index)
                  end
                  s14 << r18
                end
              end
              if s14.last
                r14 = instantiate_node(SyntaxNode,input, i14...index, s14)
                r14.extend(Expressions5)
                r14.extend(Expressions6)
              else
                @index = i14
                r14 = nil
              end
              if r14
                r3 = r14
              else
                @index = i3
                r3 = nil
              end
            end
          end
        end
        s1 << r3
        if r3
          r21 = _nt_nl
          if r21
            r20 = r21
          else
            r20 = instantiate_node(SyntaxNode,input, index...index)
          end
          s1 << r20
        end
      end
      if s1.last
        r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
        r1.extend(Expressions7)
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
    r0.extend(Expressions8)

    node_cache[:expressions][start_index] = r0

    r0
  end

  module Indentation0
    def depth
      text_value.length / 2
    end
  end

  def _nt_indentation
    start_index = index
    if node_cache[:indentation].has_key?(index)
      cached = node_cache[:indentation][index]
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
    r0.extend(Indentation0)

    node_cache[:indentation][start_index] = r0

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
    def to_ast(context)
      tail.elements.inject head.to_ast(context) do |ast, modifier|
        modifier.to_ast context, ast
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
              r7 = _nt_string
              if r7
                r1 = r7
              else
                @index = i1
                r1 = nil
              end
            end
          end
        end
      end
    end
    s0 << r1
    if r1
      s8, i8 = [], index
      loop do
        r9 = _nt_expression_modifier
        if r9
          s8 << r9
        else
          break
        end
      end
      r8 = instantiate_node(SyntaxNode,input, i8...index, s8)
      s0 << r8
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

  module ExpressionModifier0
    def modifier
      elements[1]
    end
  end

  module ExpressionModifier1
    def to_ast(context, to_modify)
      modifier.to_ast context, to_modify
    end
  end

  def _nt_expression_modifier
    start_index = index
    if node_cache[:expression_modifier].has_key?(index)
      cached = node_cache[:expression_modifier][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r2 = _nt_sp
    if r2
      r1 = r2
    else
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      i3 = index
      r4 = _nt_binary_op_call
      if r4
        r3 = r4
      else
        r5 = _nt_send_assignemnt_message
        if r5
          r3 = r5
        else
          r6 = _nt_send_message
          if r6
            r3 = r6
          else
            r7 = _nt_assignment
            if r7
              r3 = r7
            else
              @index = i3
              r3 = nil
            end
          end
        end
      end
      s0 << r3
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(ExpressionModifier0)
      r0.extend(ExpressionModifier1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:expression_modifier][start_index] = r0

    r0
  end

  module Assignment0
    def value
      elements[2]
    end
  end

  module Assignment1
    def to_ast(context, target_ast)
      Ddir::Ast::Assignment.new target: target_ast, value: value.to_ast(context)
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
    def to_ast(context, receiver_ast)
      Ddir::Ast::SendMessage.new \
        depth:     context.depth,
        receiver:  receiver_ast,
        name:      :"#{name.text_value}=",
        arguments: [assignment.value.to_ast(context)],
        block:     nil
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

    def suffix
      elements[2]
    end

    def args
      elements[3]
    end

    def maybe_block
      elements[5]
    end
  end

  module SendMessage2
    def to_ast(context, receiver_ast)
      Ddir::Ast::SendMessage.new \
        depth:     context.depth,
        receiver:  receiver_ast,
        name:      (name.text_value + suffix.text_value).intern,
        arguments: args.elements.map { |arg| arg.expression.to_ast context },
        block:     (maybe_block.to_ast context unless maybe_block.empty?)
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
        i3 = index
        if has_terminal?('!', false, index)
          r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('!')
          r4 = nil
        end
        if r4
          r3 = r4
        else
          if has_terminal?('?', false, index)
            r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure('?')
            r5 = nil
          end
          if r5
            r3 = r5
          else
            if has_terminal?('', false, index)
              r6 = instantiate_node(SyntaxNode,input, index...(index + 0))
              @index += 0
            else
              terminal_parse_failure('')
              r6 = nil
            end
            if r6
              r3 = r6
            else
              @index = i3
              r3 = nil
            end
          end
        end
        s0 << r3
        if r3
          s7, i7 = [], index
          loop do
            i8, s8 = index, []
            r9 = _nt_sp
            s8 << r9
            if r9
              r10 = _nt_expression
              s8 << r10
            end
            if s8.last
              r8 = instantiate_node(SyntaxNode,input, i8...index, s8)
              r8.extend(SendMessage0)
            else
              @index = i8
              r8 = nil
            end
            if r8
              s7 << r8
            else
              break
            end
          end
          r7 = instantiate_node(SyntaxNode,input, i7...index, s7)
          s0 << r7
          if r7
            r12 = _nt_sp
            if r12
              r11 = r12
            else
              r11 = instantiate_node(SyntaxNode,input, index...index)
            end
            s0 << r11
            if r11
              r14 = _nt_block
              if r14
                r13 = r14
              else
                r13 = instantiate_node(SyntaxNode,input, index...index)
              end
              s0 << r13
            end
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
    def to_ast(context)
      # identify the expressions
      expressions = params.expression_asts(context)
      expressions << body.to_ast(context) unless body.empty?

      # always have a body b/c block values could add to it later
      body = Ddir::Ast::Expressions.new(expressions: expressions, depth: context.depth.next)

      # build the block
      Ddir::Ast::Block.new \
        depth:  context.depth,
        params: params.to_ast(context),
        body:   body
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
    def param
      elements[3]
    end
  end

  module Params1
    def first
      elements[1]
    end

    def rest
      elements[2]
    end

  end

  module Params2
    def all_params
      params = []
      params << first unless first.empty?
      params.concat rest.elements.map(&:param)
      params.inject(0) { |var_offset, param| param.name_anon_vars_from_offset var_offset }
      params
    end

    def expression_asts(context)
      all_params.flat_map { |param| param.expression_asts context }
    end

    def to_ast(context)
      Ddir::Ast::Params.new params: all_params.flat_map { |param| param.param_asts context }
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
    r2 = _nt_sp
    if r2
      r1 = r2
    else
      r1 = instantiate_node(SyntaxNode,input, index...index)
    end
    s0 << r1
    if r1
      r4 = _nt_param
      if r4
        r3 = r4
      else
        r3 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r3
      if r3
        s5, i5 = [], index
        loop do
          i6, s6 = index, []
          r8 = _nt_sp
          if r8
            r7 = r8
          else
            r7 = instantiate_node(SyntaxNode,input, index...index)
          end
          s6 << r7
          if r7
            if has_terminal?(',', false, index)
              r9 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure(',')
              r9 = nil
            end
            s6 << r9
            if r9
              r11 = _nt_sp
              if r11
                r10 = r11
              else
                r10 = instantiate_node(SyntaxNode,input, index...index)
              end
              s6 << r10
              if r10
                r12 = _nt_param
                s6 << r12
              end
            end
          end
          if s6.last
            r6 = instantiate_node(SyntaxNode,input, i6...index, s6)
            r6.extend(Params0)
          else
            @index = i6
            r6 = nil
          end
          if r6
            s5 << r6
          else
            break
          end
        end
        r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
        s0 << r5
        if r5
          r14 = _nt_sp
          if r14
            r13 = r14
          else
            r13 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r13
        end
      end
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

  module Param0
    def var
      elements[0]
    end

    def default_value
      elements[2]
    end
  end

  module Param1
    def param_asts(context)
      ast = if default_value.empty?
        Ddir::Ast::RequiredParam.new name: var.text_value.intern
      else
        Ddir::Ast::DefaultParam.new name: var.text_value.intern,
                                    value: default_value.to_ast(context)
      end
      [ast]
    end
    def expression_asts(context)
      []
    end
    def name_anon_vars_from_offset(offset)
      offset
    end
  end

  module Param2
  end

  module Param3
    def var
      elements[0]
    end

  end

  module Param4
    def param_asts(context)
      [Ddir::Ast::OrdinalParam.new(name: var.text_value.intern)]
    end
    def expression_asts(context)
      []
    end
    def name_anon_vars_from_offset(offset)
      offset
    end
  end

  module Param5
  end

  module Param6
    def var
      elements[0]
    end

  end

  module Param7
    def param_asts(context)
      [Ddir::Ast::OrdinalParam.new(name: @anon_name)]
    end
    def expression_asts(context)
      [ Ddir::Ast::Assignment.new(
          target: var.to_ast(context),
          value:  Ddir::Ast::LocalVariable.new(name: @anon_name),
        ),
      ]
    end
    def name_anon_vars_from_offset(offset)
      @anon_name = :"_arg#{offset}"
      offset.next
    end
  end

  module Param8
    def expression
      elements[0]
    end
  end

  module Param9
    # doesn't work yet
    def param_asts(context)
      [expression.to_ast(context)]
    end
    def expression_asts(context)
      [expression.to_ast(context)]
    end
    def name_anon_vars_from_offset(offset)
      offset
    end
  end

  def _nt_param
    start_index = index
    if node_cache[:param].has_key?(index)
      cached = node_cache[:param][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    i1, s1 = index, []
    r2 = _nt_local_variable
    s1 << r2
    if r2
      if has_terminal?(':', false, index)
        r3 = instantiate_node(SyntaxNode,input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure(':')
        r3 = nil
      end
      s1 << r3
      if r3
        r5 = _nt_expression
        if r5
          r4 = r5
        else
          r4 = instantiate_node(SyntaxNode,input, index...index)
        end
        s1 << r4
      end
    end
    if s1.last
      r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
      r1.extend(Param0)
      r1.extend(Param1)
    else
      @index = i1
      r1 = nil
    end
    if r1
      r0 = r1
    else
      i6, s6 = index, []
      r7 = _nt_local_variable
      s6 << r7
      if r7
        i8 = index
        i9, s9 = index, []
        r11 = _nt_sp
        if r11
          r10 = r11
        else
          r10 = instantiate_node(SyntaxNode,input, index...index)
        end
        s9 << r10
        if r10
          i12 = index
          if has_terminal?(',', false, index)
            r13 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(',')
            r13 = nil
          end
          if r13
            r12 = r13
          else
            if has_terminal?(')', false, index)
              r14 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure(')')
              r14 = nil
            end
            if r14
              r12 = r14
            else
              @index = i12
              r12 = nil
            end
          end
          s9 << r12
        end
        if s9.last
          r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
          r9.extend(Param2)
        else
          @index = i9
          r9 = nil
        end
        if r9
          @index = i8
          r8 = instantiate_node(SyntaxNode,input, index...index)
        else
          r8 = nil
        end
        s6 << r8
      end
      if s6.last
        r6 = instantiate_node(SyntaxNode,input, i6...index, s6)
        r6.extend(Param3)
        r6.extend(Param4)
      else
        @index = i6
        r6 = nil
      end
      if r6
        r0 = r6
      else
        i15, s15 = index, []
        r16 = _nt_instance_variable
        s15 << r16
        if r16
          i17 = index
          i18, s18 = index, []
          r20 = _nt_sp
          if r20
            r19 = r20
          else
            r19 = instantiate_node(SyntaxNode,input, index...index)
          end
          s18 << r19
          if r19
            i21 = index
            if has_terminal?(',', false, index)
              r22 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure(',')
              r22 = nil
            end
            if r22
              r21 = r22
            else
              if has_terminal?(')', false, index)
                r23 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure(')')
                r23 = nil
              end
              if r23
                r21 = r23
              else
                @index = i21
                r21 = nil
              end
            end
            s18 << r21
          end
          if s18.last
            r18 = instantiate_node(SyntaxNode,input, i18...index, s18)
            r18.extend(Param5)
          else
            @index = i18
            r18 = nil
          end
          if r18
            @index = i17
            r17 = instantiate_node(SyntaxNode,input, index...index)
          else
            r17 = nil
          end
          s15 << r17
        end
        if s15.last
          r15 = instantiate_node(SyntaxNode,input, i15...index, s15)
          r15.extend(Param6)
          r15.extend(Param7)
        else
          @index = i15
          r15 = nil
        end
        if r15
          r0 = r15
        else
          i24, s24 = index, []
          r25 = _nt_expression
          s24 << r25
          if s24.last
            r24 = instantiate_node(SyntaxNode,input, i24...index, s24)
            r24.extend(Param8)
            r24.extend(Param9)
          else
            @index = i24
            r24 = nil
          end
          if r24
            r0 = r24
          else
            @index = i0
            r0 = nil
          end
        end
      end
    end

    node_cache[:param][start_index] = r0

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
    def to_ast(context)
      name_symbol = name.empty? ? :call : name.to_ast(context).value
      Ddir::Ast::EntryLocation.new \
        depth: context.depth,
        name:  name_symbol,
        body:  (body.to_ast(context) unless body.empty?)
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
            r9 = _nt_block
            if r9
              r8 = r9
            else
              r8 = instantiate_node(SyntaxNode,input, index...index)
            end
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
    def to_ast(context, lhs)
      Ddir::Ast::BinaryExpression.new left_child:  lhs,
                                      operator:    operator.text_value.intern,
                                      right_child: rhs.to_ast(context)
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
    def to_ast(context)
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
    def to_ast(context)
      variable.to_ast(context)
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
    def to_ast(context)
      Ddir::Ast::LocalVariable.new name: text_value.intern
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
    def to_ast(context)
      Ddir::Ast::InstanceVariable.new name: text_value.intern
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
        if has_terminal?('<<', false, index)
          r3 = instantiate_node(SyntaxNode,input, index...(index + 2))
          @index += 2
        else
          terminal_parse_failure('<<')
          r3 = nil
        end
        if r3
          r0 = r3
        else
          @index = i0
          r0 = nil
        end
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
    def to_ast(context)
      Ddir::Ast::Integer.new value: text_value.to_i
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
    def to_ast(context)
      Ddir::Ast::Symbol.new value: value.text_value.intern
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

  module String0
    def value
      elements[1]
    end

  end

  module String1
    def value
      elements[1]
    end

  end

  module String2
    def to_ast(context)
      Ddir::Ast::String.new value: value.text_value
    end
  end

  def _nt_string
    start_index = index
    if node_cache[:string].has_key?(index)
      cached = node_cache[:string][index]
      if cached
        cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    i1, s1 = index, []
    if has_terminal?('"', false, index)
      r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('"')
      r2 = nil
    end
    s1 << r2
    if r2
      s3, i3 = [], index
      loop do
        if has_terminal?('\G[^"]', true, index)
          r4 = true
          @index += 1
        else
          r4 = nil
        end
        if r4
          s3 << r4
        else
          break
        end
      end
      r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
      s1 << r3
      if r3
        if has_terminal?('"', false, index)
          r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('"')
          r5 = nil
        end
        s1 << r5
      end
    end
    if s1.last
      r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
      r1.extend(String0)
    else
      @index = i1
      r1 = nil
    end
    if r1
      r0 = r1
      r0.extend(String2)
    else
      i6, s6 = index, []
      if has_terminal?("'", false, index)
        r7 = instantiate_node(SyntaxNode,input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure("'")
        r7 = nil
      end
      s6 << r7
      if r7
        s8, i8 = [], index
        loop do
          if has_terminal?('\G[^\']', true, index)
            r9 = true
            @index += 1
          else
            r9 = nil
          end
          if r9
            s8 << r9
          else
            break
          end
        end
        r8 = instantiate_node(SyntaxNode,input, i8...index, s8)
        s6 << r8
        if r8
          if has_terminal?("'", false, index)
            r10 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("'")
            r10 = nil
          end
          s6 << r10
        end
      end
      if s6.last
        r6 = instantiate_node(SyntaxNode,input, i6...index, s6)
        r6.extend(String1)
      else
        @index = i6
        r6 = nil
      end
      if r6
        r0 = r6
        r0.extend(String2)
      else
        @index = i0
        r0 = nil
      end
    end

    node_cache[:string][start_index] = r0

    r0
  end

end

class DayDreamInRubyParser < Treetop::Runtime::CompiledParser
  include DayDreamInRuby
end

