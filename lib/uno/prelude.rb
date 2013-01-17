module Uno
  module Prelude
    extend self
    
    def record
      Hash.new { |h, k| h[k] = [] }
    end

    def defs
      @defs ||= {}
    end

    def define(name, value)
      defs[name] = value
    end

    define :puts, proc { |int, *args|
      puts(*args)
    }
  end
end

