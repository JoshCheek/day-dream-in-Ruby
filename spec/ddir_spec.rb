require 'spec_helper'

RSpec.describe 'My language' do
  class << self
    alias are it
  end

  context 'parsing' do
    example 'local vars are identifiers: made of lowercase a-z and underscores' do
      parses! 'x',   first: { type: :local_variable, name: 'x' }
      parses! '_',   first: { type: :local_variable, name: '_' }
      parses! '_x_', first: { type: :local_variable, name: '_x_' }
      parses! 'a_b', first: { type: :local_variable, name: 'a_b' }
      parses! [*'a'..'z'].join, first: {
        type:  :local_variable,
        name: 'abcdefghijklmnopqrstuvwxyz',
      }
    end

    example 'ivars are identifiers with an @ prefix' do
      parses! '@x', first: { type: :instance_variable, name: '@x' }
    end

    example 'self is indicated with an "@"' do
      parses! '@', first: { type: :self }
    end

    example 'method calls are to the RHS of a "."' do
      parses! 'a.b', first: {
        type:      :send_message,
        receiver:  { type: :local_variable, name: 'a' },
        name:      'b',
        arguments: [],
      }
      parses! 'x.y.z', first: {
        type:      :send_message,
        name:      'z',
        arguments: [],
        receiver:  {
          type:      :send_message,
          name:      'y',
          arguments: [],
          receiver:  { type: :local_variable, name: 'x' },
        },
      }
    end

    example 'lines beginning with method calls are invoked on the result of the previous line'
    example 'setters are method calls on the LHS of an assignment arrow'
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
