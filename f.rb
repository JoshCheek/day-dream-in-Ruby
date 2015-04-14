require 'pp'

class Node
  attr_accessor :parent, :depth

  def initialize(parent:Node::Null.new, depth:0)
    self.parent = parent
    self.depth  = depth
  end

  def inspect(attr_inspect='')
    if attr_inspect.empty?
      "(#{self.class})"
    else
      "(#{self.class}#{attr_inspect.gsub /^/, '  '})"
    end
  end

  def as_json(additional_attrs={})
    {depth: depth}.merge additional_attrs
  end
end

class Node::Null < Node
  def initialize
    super parent: self
  end
  def as_json
    super type: :null
  end
end

class Node::Expressions < Node
  attr_accessor :children
  def initialize(children:[], **rest)
    self.children = children
    super rest
  end
  def to_s
    children.join("\n")
  end
  def inspect
    children_inspect = children.map(&:inspect).join("\n, ").gsub(/^/, '  ')
    super "children=[\n#{children_inspect}\n]"
  end
  def declare(node)
    if depth < node.depth
      children.last.declare node
    else
      node.parent = self
      children << node
    end
    self
  end
  def modifier(node)
    replacement_child = if depth < node.depth
      children.pop.modifier node
    else
      node.modify children.pop
    end
    children << replacement_child
    self
  end
  def as_json
    super type: :expressions, children: children.map(&:as_json)
  end
end

class Node::Self < Node
  def to_s
    'self'
  end
  def as_json
    super type: :self
  end
end

class Node::Send < Node
  attr_accessor :target, :name, :block
  def initialize(target:nil, name:name, block:nil, **rest)
    self.target = target
    self.name   = name
    self.block  = block
    super rest
  end
  def to_s
    "#{target}.#{name}#{block}"
  end
  def modify(receiver)
    self.target = receiver
    receiver.parent = self
    self
  end
  def modifier(node)
    if depth + 1 == node.depth
      node.modify self
    elsif depth == node.depth
      node.modify self
    else
      block.modifier node
      self
    end
  end
  def declare(node)
    self.block ||= Node::Block.new depth: node.depth, parent: self
    block.declare node
    self
  end
  def inspect
    super "name=#{name.inspect}\ntarget=#{target.inspect}\nblock=#{block.inspect}"
  end
  def as_json
    super type: :send, name: name, target: target.as_json, block: (block&&block.as_json)
  end
end

class Node::Block < Node
  attr_accessor :body
  def initialize(body:Node::Expressions.new, **rest)
    super rest
    body.parent = self
    body.depth  = depth
    self.body   = body
  end
  def to_s
    " { #{body} }"
  end
  def inspect
    super "body=#{body.inspect}"
  end
  def declare(node)
    body.declare node
    self
  end
  def modifier(node)
    body.modifier node
    self
  end
  def as_json
    super type: :block, body: body.as_json
  end
end

class Node::Local < Node
  attr_accessor :name
  def initialize(name:, **rest)
    self.name = name
    super rest
  end
  def inspect
    super "name=#{name.inspect}"
  end
  def to_s
    name.to_s
  end
  def modifier(node)
    node.modify self
  end
  def declare(node)
    raise "Shouldn't have had #{node.inspect} declared to #{inspect}"
  end
  def as_json
    super type: :local, name: name
  end
end

class Node::Builder
  attr_accessor :depth, :root, :current
  def initialize
    self.depth = 0
    self.root  = Node::Expressions.new depth: depth
  end
  def declare(node)
    node.depth   = depth
    root.declare node
  end
  def modifier(node)
    node.depth   = depth
    root.modifier node
  end
  def indentation(indentation)
    self.depth = indentation.length / 2
  end
end

# @.a.a2
#   b
#     .c
#     .c2
#   .d
#     e
# x.b
builder = Node::Builder.new
builder.declare      Node::Self.new
builder.modifier     Node::Send.new(name: :a)
builder.modifier     Node::Send.new(name: :a2)
builder.indentation  '  '
builder.declare      Node::Local.new(name: :b)
builder.indentation  '    '
builder.modifier     Node::Send.new(name: :c)
builder.modifier     Node::Send.new(name: :c2)
builder.indentation  '  '
builder.modifier     Node::Send.new(name: :d)
builder.indentation  '    '
builder.declare      Node::Local.new(name: :e)
builder.indentation  ''
builder.declare      Node::Local.new(name: :x)
builder.modifier     Node::Send.new(name: :b)

puts builder.root
puts
pp builder.root.as_json
puts
p builder.root

# >> self.a.a2 { b.c.c2 }.d { e }
# >> x.b
# >>
# >> {:depth=>0,
# >>  :type=>:expressions,
# >>  :children=>
# >>   [{:depth=>1,
# >>     :type=>:send,
# >>     :name=>:d,
# >>     :target=>
# >>      {:depth=>0,
# >>       :type=>:send,
# >>       :name=>:a2,
# >>       :target=>
# >>        {:depth=>0,
# >>         :type=>:send,
# >>         :name=>:a,
# >>         :target=>{:depth=>0, :type=>:self},
# >>         :block=>nil},
# >>       :block=>
# >>        {:depth=>1,
# >>         :type=>:block,
# >>         :body=>
# >>          {:depth=>1,
# >>           :type=>:expressions,
# >>           :children=>
# >>            [{:depth=>2,
# >>              :type=>:send,
# >>              :name=>:c2,
# >>              :target=>
# >>               {:depth=>2,
# >>                :type=>:send,
# >>                :name=>:c,
# >>                :target=>{:depth=>1, :type=>:local, :name=>:b},
# >>                :block=>nil},
# >>              :block=>nil}]}}},
# >>     :block=>
# >>      {:depth=>2,
# >>       :type=>:block,
# >>       :body=>
# >>        {:depth=>2,
# >>         :type=>:expressions,
# >>         :children=>[{:depth=>2, :type=>:local, :name=>:e}]}}},
# >>    {:depth=>0,
# >>     :type=>:send,
# >>     :name=>:b,
# >>     :target=>{:depth=>0, :type=>:local, :name=>:x},
# >>     :block=>nil}]}
# >>
# >> (Node::Expressions  children=[
# >>     (Node::Send  name=:d
# >>       target=(Node::Send  name=:a2
# >>         target=(Node::Send  name=:a
# >>           target=(Node::Self)
# >>           block=nil)
# >>         block=(Node::Block  body=(Node::Expressions  children=[
# >>               (Node::Send  name=:c2
# >>                 target=(Node::Send  name=:c
# >>                   target=(Node::Local  name=:b)
# >>                   block=nil)
# >>                 block=nil)
# >>             ])))
# >>       block=(Node::Block  body=(Node::Expressions  children=[
# >>             (Node::Local  name=:e)
# >>           ])))
# >>     , (Node::Send  name=:b
# >>       target=(Node::Local  name=:x)
# >>       block=nil)
# >>   ])
