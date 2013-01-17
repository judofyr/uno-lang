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
      attr_reader :scope, :variants
      def initialize(scope, variants)
        @scope = scope
        @variants = variants
      end

      def call(int, *args)
        @variants.each do |variant|
          begin
            variant.check(int, *args)
          rescue
            next
          end

          begin
            scope = Scope.new(@scope)
            old_scope = int.scope
            int.scope = scope
            return variant.call(int, *args)
          ensure
            int.scope = old_scope
          end
        end
      end
    end

    class BVariant
      attr_reader :code, :params
      def initialize(code, params)
        @code = code
        @params = params
      end

      def check(int, *args)
        @params.each_with_index do |(type, name, req), idx|
          if req
            rec = int.process(req)
            checker = rec["check"].last
            checker.call(int, args[idx])
          end
        end
      end

      def call(int, *args)
        scope = int.scope

        @params.each_with_index do |(type, name, req), idx|
          scope[name] = args[idx]
        end

        int.process(@code)
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

    def process_recempty
      {}
    end

    def process_record(value, rec = nil)
      rec ||= Hash.new { |h, k| h[k] = [] }

      case value[0]
      when :recset
        rec[value[1]] << process(value[2])
      when :recmethod
        block = process(value[2])
        bvar = block.variants[0]
        bvar.params.unshift([:param, "self", nil])
        bvar.params.unshift([:param, "env", nil])
        rec[value[1]] << block
      when :recremove
        rec[value[1]].pop
      when :recupdate
        rec[value[1]].pop
        rec[value[1]] << process(value[2])
      when :recsplat
        process(value[1]).each do |key, value|
          rec[key].concat(value)
        end
      when :recmerge
        process_record(value[1], rec)
        process_record(value[2], rec)
      else
        raise "Can't handle: #{value[0]}"
      end

      rec
    end

    def process_access(base, name)
      base = process(base)
      values = base[name]
      if values.empty?
        raise "Missing field: #{name}"
      end
      values.last
    end

    def process_assign(name, value)
      @scope[name] = process(value)
    end

    def process_call(base, args)
      base = process(base)
      args = args.map { |x| process(x) }
      base.call(self, *args)
    end

    def process_method(base, name, args)
      base = process(base)
      env = base["_scope"].last.call(self, base)
      block = env[name].last
      args = args.map { |x| process(x) }
      block.call(self, env, base, *args)
    end

    def process_op(type, left, right)
      process(left).send(type, process(right))
    end

    def process_block(vars)
      vars = vars.map { |x| process(x) }
      Block.new(@scope, vars)
    end

    def process_bvariant(code, params)
      BVariant.new(code, params)
    end

    def process_if(cond, body)
      process(body) if process(cond)
    end
  end
end

