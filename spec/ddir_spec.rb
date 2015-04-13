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

    specify 'method calls are to the RHS of a "."' do
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

    specify 'lines beginning with method calls are invoked on the result of the previous line'

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
            body: { type: :none },
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

      specify 'the body is anything to the right of the argument list' do
        parses! '@.m () a.b', block: {
            body: { name: :b, receiver: {name: :a} }
          }
      end
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
    end

    context 'entry locations' do
      it 'can be anonymous functions' do
        e = eval '-> (x) x + x', wrap: true
        expect(e.call 11).to eq 22
      end

      it 'can be named classes' do
        e = eval '-> :A ()', wrap: true
        expect(e::A).to be_a_kind_of Class
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

    context 'blocks' do
      are 'indicated by an arg list and inline body'
      are 'indicated by an arg list and indentation'
      are 'indicated by indentation without an arg list'
    end

    context 'method calls' do
      def define(name, private:false, &block)
        singleton_class.class_eval do
          define_method name, &block
          private(name) if private
        end
        methods = private ? private_methods : public_methods
        expect(methods).to include name
      end

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
      xit 'can call private setters on self, and returns the assigned value' do
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
