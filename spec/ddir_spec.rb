require 'spec_helper'

RSpec.describe 'My language' do
  class << self
    alias are it
  end

  context 'parsing' do
    specify 'empty docs get the null-expression' do
      parses! '', type: :expressions, expressions: []
    end

    specify 'integers are made up of uhm. digits' do
      parses! '1', type: :integer, value: 1
      parses! '19329', type: :integer, value: 19329
    end

    specify 'symbols are sequences of characters that start with colons' do
      parses! ':x',   type: :symbol, value: :x
      parses! ':z2',  type: :symbol, value: :z2
      parses! ':a_b', type: :symbol, value: :a_b
      parses! ':A',   type: :symbol, value: :A
    end

    specify 'strings are sequences of characters surrounded by quotes' do
      parses! %(""),     type: :string, value: ''
      parses! %(''),     type: :string, value: ""
      parses! %("Aa 1"), type: :string, value: 'Aa 1'
      parses! %('Aa 1'), type: :string, value: 'Aa 1'
      parses! %('"a"'),  type: :string, value: '"a"'
      parses! %("'a'"),  type: :string, value: "'a'"
    end

    specify 'local vars are identifiers: start w/ lowercase a-z and underscores, bodies can also have digits and uppercase characters' do
      parses! 'x',   type: :local_variable, name: :x
      parses! '_',   type: :local_variable, name: :_
      parses! '_x_', type: :local_variable, name: :_x_
      parses! 'a_b', type: :local_variable, name: :a_b
      parses! [*'a'..'z'].join, type: :local_variable,
                                name: :abcdefghijklmnopqrstuvwxyz
      parses! 'a123', type: :local_variable, name: :a123
      parses! 'aA', type: :local_variable, name: :aA
    end

    specify 'ivars are identifiers with an @ prefix' do
      parses! '@x', type: :instance_variable, name: :@x
    end

    specify 'self is indicated with an "@"' do
      parses! '@', type: :self
    end

    specify 'hashes introduce comments until the end of the line' do
      parses! "# o m g\n1", type: :integer, value: 1
    end

    specify 'method calls are identifiers to the RHS of a "."' do
      parses! 'a.b',
        type:      :send_message,
        receiver:  { type: :local_variable, name: :a },
        name:      :b,
        block:     nil,
        arguments: []
      parses! 'x.y.z',
        type:      :send_message,
        name:      :z,
        arguments: [],
        block:     nil,
        receiver:  {
          type:      :send_message,
          name:      :y,
          arguments: [],
          block:     nil,
          receiver:  { type: :local_variable, name: :x },
        }
    end

    specify 'method calls may end in !, and ?' do
      parses! 'a.b?', name: :b?
      parses! 'a.b!', name: :b!
    end

    specify 'spaces delimit method arguments' do
      parses! '@.a b c',
        type:     :send_message,
        receiver: {type: :self},
        name:     :a,
        block:    nil,
        arguments: [
          {type: :local_variable, name: :b},
          {type: :local_variable, name: :c},
        ]
    end

    specify 'lines beginning with method calls are invoked on the result of the previous line' do
      parses! "@\n  .a 1",
        type:      :send_message,
        receiver:  {type: :self},
        name:      :a,
        block:     nil,
        arguments: [{type: :integer, value: 1}]
    end

    specify 'setters are method calls on the LHS of an assignment arrow' do
      parses! 'a <- 1',
        type:   :assignment,
        target: { type: :local_variable, name: :a },
        value:  { type: :integer, value: 1 }
    end

    describe 'blocks' do
      specify 'parens are argument lists' do
        parses! '@.m (x) x',
          type:      :send_message,
          receiver:  { type: :self },
          name:      :m,
          arguments: [],
          block:     {
            type:        :block,
            param_names: [:x],
            body:        { type: :local_variable, name: :x },
          }
        parses! '@.m a (x) x',
          receiver:  { type: :self },
          block:     { param_names: [:x] },
          arguments: [{name: :a}],
          name:      :m
        parses! '@.m a ()',
          receiver:  { type: :self },
          block:     {
            param_names: [],
            body: nil,
          }
      end

      specify 'argument lists can be empty' do
        parses! '@.m () a',  block: { param_names: [] }
        parses! '@.m (a) a', block: { param_names: [:a] }
      end

      specify 'arguments can be separated by commas' do
        parses! '@.m (a,b) a', block: { param_names: [:a, :b] }
        parses! '@.m (a, b ,c , d) a', block: { param_names: [:a, :b, :c, :d] }
      end

      specify 'arguments can assign directly to instance variables' do
        parses! '@.m (@a, @b) 1', block: {
          param_names: [:_arg0, :_arg1],
          body: [
            { type:   :assignment,
              target: { type: :instance_variable, name: :@a },
              value:  { type: :local_variable,    name: :_arg0 },
            },
            { type:   :assignment,
              target: { type: :instance_variable, name: :@b },
              value:  { type: :local_variable,    name: :_arg1 },
            },
            { type: :integer, value: 1 },
          ]
        }
      end

      specify 'the body is anything to the right of the argument list' do
        parses! '@.m () a.b', block: {
            body: { name: :b, receiver: {name: :a} }
          }
      end

      specify 'the body is anything indented on the next line' do
        parses! "@.m ()\n  a\n  b", block: {
            body: [
              { type: :local_variable, name: :a },
              { type: :local_variable, name: :b },
            ]
          }
        parses! "@.m\n  a\n  b", block: {
            body: [
              { type: :local_variable, name: :a },
              { type: :local_variable, name: :b },
            ]
          }
      end
    end

    example 'pushing it a bit' do
      ddir_code = <<-DDIR.gsub /^\s*/, ''
        x + x
        x - @y
        x - @y
        abc.def.ghi
        -> (some_arg, other_arg) some_arg + x - y.abc 123 (x) x + @x + other_arg
      DDIR
      parses! ddir_code, expressions: [
        { type: :binary_expression, operator: :+ },
        { type: :binary_expression, operator: :- },
        { type: :binary_expression, operator: :- },
        { type: :send_message, name: :ghi, receiver: {
            type: :send_message, name: :def, receiver: {
              type: :local_variable, name: :abc
            },
          },
        },
        { type: :entry_location, body: {
            type: :block, param_names: [:some_arg, :other_arg], body: {
              type:        :binary_expression,
              left_child:  { type: :local_variable, name: :some_arg },
              operator:    :+,
              right_child: {
                type:        :binary_expression,
                left_child:  { type: :local_variable, name: :x },
                operator:    :-,
                right_child: {
                  type:      :send_message,
                  name:      :abc,
                  receiver:  { type: :local_variable, name: :y },
                  arguments: [ {type: :integer, value: 123} ],
                  block:     {
                    param_names: [:x],
                    body:        {
                      type:        :binary_expression,
                      operator:    :+,
                      left_child:  { type: :local_variable, name: :x },
                      right_child: {
                        type:        :binary_expression,
                        left_child:  { type: :instance_variable, name: :@x },
                        operator:    :+,
                        right_child: { type: :local_variable, name: :other_arg},
                      }
                    }
                  }
                },
              },
            },
          },
        },
      ]
    end

    example 'pushing it a bit more' do
      ddir_code = <<-DDIR
        @.a.a2
          b
            .c
            .c2
          .d
            e
        x.b
      DDIR
      ddir_code.gsub! /^#{ddir_code[/\A */]}/, ''
      parses! ddir_code, expressions: [
        { type: :send_message, name: :d, block: {
            param_names: [],
            body: [{type: :local_variable, name: :e}]
          }, receiver: {
            type: :send_message, name: :a2, arguments: [], block: {
              param_names: [],
              body:        [
                { type:      :send_message,
                  name:      :c2,
                  arguments: [],
                  block:     nil,
                  receiver:  {
                    type:      :send_message,
                    name:      :c,
                    arguments: [],
                    block:     nil,
                    receiver:  { type: :local_variable, name: :b },
                  },
                },
              ],
            },
            receiver: {
              type:      :send_message,
              name:      :a,
              arguments: [],
              block:     nil,
              receiver:  { type: :self },
            }
          }
        },
        { type: :send_message, name: :b, arguments: [], block: nil, receiver: {
            type: :local_variable, name: :x,
          },
        },
      ]
    end
  end

  context 'Generated code' do
    context 'literals' do
      example '123 is an integer' do
        expect(eval '123').to eq 123
      end
      example ':abc is a symbol' do
        expect(eval ':abc').to eq :abc
      end
      example "'abc' is a string" do
        expect(eval "'abc'").to eq 'abc'
      end
    end

    context 'entry locations' do
      context 'at the toplevel' do
        it 'can be anonymous functions' do
          e = eval '-> (x) x + x', wrap: true
          expect(e.call 11).to eq 22
        end

        it 'can be named classes with inline blocks' do
          e = eval '-> :A () @ivar <- 123', wrap: true
          expect(e::A).to be_a_kind_of Class
          expect(e::A.instance_variable_get(:@ivar)).to eq 123
        end

        it 'can be named classes with nextline blocks' do
          e = eval "-> :A ()\n  @ivar <- 123", wrap: true
          expect(e::A).to be_a_kind_of Class
          expect(e::A.instance_variable_get(:@ivar)).to eq 123

          e = eval "-> :A\n  @ivar <- 123", wrap: true
          expect(e::A).to be_a_kind_of Class
          expect(e::A.instance_variable_get(:@ivar)).to eq 123
        end
      end

      context 'within a class definition' do
        it 'defines methods' do
          e = eval "-> :A ()\n"\
                   "  -> :get () @var\n"\
                   "\n"\
                   "  -> :set () @var <- :omg",
                   wrap: true
          a = e::A.new
          expect(a.get).to eq nil
          a.set
          expect(a.get).to eq :omg

          e = eval "-> :A ()\n"\
                   "  -> :get\n"\
                   "    @var\n"\
                   "  -> :set ()\n"\
                   "    @var <- :omg\n",
                   wrap: true
          a = e::A.new
          expect(a.get).to eq nil
          a.set
          expect(a.get).to eq :omg
        end
      end
    end

    context 'self' do
      it 'is represented with @' do
        expect(eval '@').to equal self
      end
      it 'calls methods on self with @.method' do
        define_singleton_method(:zomg) { 123 }
        expect(eval '@.zomg').to eq 123
      end
    end

    context 'the assigment arrow' do
      it 'assigns locals' do
        expect(eval "a <- 1\na").to eq 1
        expect(eval "a <- 1\n@.local_variables").to include :a
      end
      it 'assigns ivars' do
        expect(@a).to eq nil
        eval '@a <- 123'
        expect(@a).to eq 123
      end
      it 'calls setters' do
        assigned = nil
        define_singleton_method(:a=) { |x| assigned = x }
        eval '@.a <- 123'
        expect(assigned).to eq 123
      end
    end

    context 'empty lines' do
      are 'ignored' do
        expect(eval '').to eq nil
        expect(eval "x <- 1\n\nx").to eq 1
      end
    end

    def define(name, private:false, &block)
      singleton_class.class_eval do
        define_method name, &block
        private(name) if private
      end
      methods = private ? private_methods : public_methods
      expect(methods).to include name
    end

    context 'blocks' do
      def call_block(code, *args_to_pass)
        define(:m) { |&block| block.call *args_to_pass }
        eval "@.m #{code}"
      end

      are 'indicated by an arg list and inline body' do
        expect(call_block '(x) x + x', 1).to eq 2
      end
      are 'indicated by an arg list and indentation' do
        expect(call_block "(x)\n  x + x", 1).to eq 2
      end
      are 'indicated by indentation without an arg list' do
        expect(call_block "\n  123").to eq 123
      end
      are 'exited when the indentation decreases' do
        expect(call_block "\n  x <- 1\n  @.defined? x").to eq 'local-variable'
        expect(call_block "\n  x <- 1\n@.defined? x").to eq nil
      end
    end

    context 'method calls' do
      it 'can call public methods on self' do
        define(:abc, private: false) { 123 }
        expect(eval '@.abc').to eq 123
      end
      it 'can call private methods on self' do
        define(:abc, private: true) { 123 }
        expect(eval '@.abc').to eq 123
      end
      it 'can call methods on other objects' do
        expect(eval '123.succ').to eq 124
      end
      it 'can pass arguments' do
        define(:abc) { |*args| "args: #{args.inspect}" }
        expect(eval '@.abc 1 2 3').to eq "args: [1, 2, 3]"
      end
      it 'can call public setters on self, and returns the assigned value' do
        sent = nil
        define(:abc=, private: false) { |x| sent = x }
        expect(eval '@.abc <- 123 ').to eq 123
        expect(sent).to eq 123
      end
      it 'can call private setters on self, and returns the assigned value' do
        # not convinced, I assume the code is being run in a private context, and so it is able to call the setter, but w/e, it's good enough for now
        sent = nil
        define(:abc=, private: true) { |x| sent = x }
        expect(eval '@.abc <- 123 ').to eq 123
        expect(sent).to eq 123
      end
      it 'can pass blocks' do
        define(:abc) { |&b| "result: #{b.call.inspect}" }
        expect(eval '@.abc () 123').to eq "result: 123"
      end
      it 'can pass args and blocks' do
        define(:abc) { |a, &b| "arg: #{a.inspect}, block: #{b.call}" }
        expect(eval '@.abc 1 () 2').to eq "arg: 1, block: 2"
      end
      it 'can repeatedly chain methods on indented lines' do
        expect(eval "'ab'\n  .chars.join '.'").to eq "a.b"
      end
    end

    context 'local variables' do
      it 'can set them' do
        expect(eval "a <- 1\n@.local_variables").to include :a
      end
      it 'can get them' do
        expect(eval "a <- 1\na + a").to eq 2
      end
    end

    context 'argument lists' do
      are 'indicated by parentheses'
      #...
    end
  end
end
