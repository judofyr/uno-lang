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
      def initialize(scope, code, params)
        @scope = scope
        @code = code
        @params = params
      end

      def call(int, *args)
        scope = Scope.new(@scope)

        @params.each_with_index do |(type, name, _), idx|
          scope[name] = args[idx]
        end

        old_scope = int.scope
        int.scope = scope
        int.process(@code)
      ensure
        int.scope = old_scope
      end
    end

    attr_accessor :scope

    def initialize
      @scope = Scope.new
      @scope["puts"] = proc { |int, *args| puts(*args) }
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

    def process_op(type, left, right)
      process(left).send(type, process(right))
    end

    def process_block(code, params)
      Block.new(@scope, code, params)
    end

    def process_if(cond, body)
      process(body) if process(cond)
    end
  end
end

