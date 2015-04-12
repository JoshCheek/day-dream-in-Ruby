module Example
  def self.call(x)
    x + x
  end

  A = Class.new do
    attr_reader :x :y
    attr_writer :z
    attr_accessor :z2

    define_method :initialize do |x, y, z:100, z2|
      @x = x
      @z = z
      self.y = y
      @z2 = z2
    end

    define_method :inline_body do
      1 + 2
    end

    define_method :multiline_body do
      from_literal = 123
      from_local   = from_literal
      from_ivar    = @z
      from_method  = z()
      from_literal + from_local + from_ivar + from_method
    end

    :chaining_with_blocks do
      [*'a'..'c']
        .map { |c| c.upcase }
        .map { |c|
          c.downcase
           .upcase
           .chars.join('.')
        }
        .map { |c| c.downcase }
        .map { |c| c*2 }
        .map.with_index { |c, i| [c.upcase, i*2] }
        .each.with_object("") { |(char, index), str|
          char  = char.downcase
          index = index/2
          if index.even?
            str << "#{index}: #{char}"
          else
            str << "nothin"
          end
        }
        .chars.each_slice(2) { |c1, c2| c1 + c2 }
        .join
        .chars.each_slice(2) { |c1, c2| c1 + c2 }.join
    end
  end
end
