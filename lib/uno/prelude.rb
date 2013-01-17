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

    define :Str, record.tap { |r|
      r["check"] << proc do |int, value|
        raise unless value.is_a?(String)
      end

      r["length"] << proc do |int, value|
        value.length
      end
    }
  end
end

