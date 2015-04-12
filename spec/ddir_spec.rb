require 'spec_helper'

RSpec.describe 'My language' do
  class << self
    alias are it
  end

  context 'parsing' do
    specify 'local vars are identifiers: made of lowercase a-z and underscores' do
      parses! 'x',   type: :local_variable, name: :x
      parses! '_',   type: :local_variable, name: :_
      parses! '_x_', type: :local_variable, name: :_x_
      parses! 'a_b', type: :local_variable, name: :a_b
      parses! [*'a'..'z'].join, type: :local_variable,
                                name: :abcdefghijklmnopqrstuvwxyz
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

    specify 'setters are method calls on the LHS of an assignment arrow'

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
      end

      specify 'argument lists can be empty' do
        parses! '@.m () a',  block: { param_names: [] }
        parses! '@.m (a) a', block: { param_names: [:a] }
      end

      specify 'arguments can be separated by commas' do
        parses! '@.m (a,b) a', block: { param_names: [:a, :b] }
        parses! '@.m (a, b ,c , d) a', block: { param_names: [:a, :b, :c, :d] }
      end

      specify 'the body is anything to the right of the argument list'
    end
  end

  context 'running', pending: true do
    context 'entry locations' do
      it 'can be anonymous functions' do
        e = eval '-> (x) x + x'
        expect(e.call 11).to eq 22
      end

      it 'can be named classes' do
        e = eval '-> :A ()'
        expect(e::A).to be_a_kind_of Class
      end
    end

    context 'self' do
      it 'is represented with @'
      it 'calls methods on self with @.method'
    end

    context 'the assigment arrow' do
      it 'assigns locals'
      it 'assigns ivars'
      it 'calls setters'
    end

    context 'blocks' do
      are 'indicated by an arg list and inline body'
      are 'indicated by an arg list and indentation'
      are 'indicated by indentation without an arg list'
    end

    context 'local variables' do
    end

    context 'argument lists' do
      are 'indicated by parentheses'
      #...
    end
  end
end
