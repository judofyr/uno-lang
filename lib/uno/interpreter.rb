module Uno
  class Interpreter
    def initialize
      @scope = {
        "puts" => proc { |val| puts(val) }
      }
    end

    def process(exp)
      send("process_#{exp[0]}", *exp[1..-1])
    end

    def process_var(name)
      @scope[name]
    end

    def process_string(str)
      str
    end

    def process_call(base, args)
      base = process(base)
      base.call(*args.map { |x| process(x) })
    end
  end
end

