Module.new do
  define_singleton_method(:call) { |x|
    x + x
  }
  
  const_set :A, Class.new  { 
    attr_reader(:x, :y)
    attr_writer(:z)
    attr_accessor(:z2)
    define_method(:initialize) { |_arg0, y, z:100, z2:|
      @x = _arg0
      self.y=(y)
      @z2 = z2
    }
    
    define_method(:inline_body) { 
      1 + 2
    }
    
    define_method(:multiline_body) { 
      from_literal = 123
      from_local = from_literal
      from_ivar = @z
      from_method = z
      from_literal + from_local + from_ivar + from_method
    }
    
    define_method(:chaining_with_blocks) { 
      "a".upto("c").map { |c|
        c.upcase
      }
      .map { |c|
        c.downcase.upcase.chars.join(".")
      }
      .map { |c|
        c.downcase
      }
      .map { |c|
        c * 2
      }
      .map.with_index { |c, i|
        c.upcase
        i * 2
      }
      .each.with_object("") { |(char, index), str|
        char.downcase
        index / 2
      }
      .chars.each_slice(2) { |c1, c2|
        c1 + c2
      }
      .chars.each_slice(2) { |c1, c2|
        c1 + c2
      }
      
    }
    
  }
  
end
