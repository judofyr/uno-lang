module Uno
  class Interpreter
    class Scope
      def initialize(parent = nil)
        @values = {}
        @parent = parent
      end

      def [](key)
        bound = @values.has_key?(key)
        raise "Can't find #{key}" if !bound && !@parent
        bound ? @values[key] : @parent[key]
      end

      def []=(key, value)
        @values[key] = value
      end
    end

    class Block
      def initialize(block, code)
        @block = block
        @code = code
      end

      def call(int)
        int.process(@code)
      end
    end

    def initialize
      @scope = {
        "puts" => proc { |int, *args| puts(*args) }
      }
    end

    def process(exp)
      send("process_#{exp[0]}", *exp[1..-1])
    end

    def process_exprs(*exprs)
      exprs.each { |exp| process(exp) }
    end

    def process_var(name)
      @scope[name]
    end

    def process_string(str)
      str
    end

    def process_integer(val)
      val
    end

    def process_assign(name, value)
      @scope[name] = process(value)
    end

    def process_call(base, args)
      base = process(base)
      args = args.map { |x| process(x) }
      base.call(self, *args)
    end

    def process_block(code)
      Block.new(@scope, code)
    end
  end
end

