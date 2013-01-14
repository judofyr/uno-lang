require 'kramer/dsl'

module Uno
  class Parser
    GrammarFile = File.expand_path('../grammar.kram', __FILE__)
    Grammar = Kramer::DSL.parse(File.read(GrammarFile))

    def self.parse(str)
      new.parse(str)
    end

    def parse(str)
      i = Grammar.new(str)
      if i.success?
        process(i.result.value)
      else
        raise i.failure_message
      end
    end

    def process(node)
      send("process_#{node.name}", node.value)
    end

    ## Numbers
    def process_num(node)
      [:integer, node[:value].val.to_i]
    end

    ## Records
    def process_recempty(node)
      [:recempty]
    end

    def process_recmerge(node)
      [:recmerge, process(node[:rest].val), process(node[:field].val)]
    end

    def process_recset(node)
      [:recset, node[:name].val, process(node[:value].val)]
    end

    def process_recupdate(node)
      [:recupdate, node[:name].val, process(node[:value].val)]
    end

    def process_recsplat(node)
      [:recsplat, process(node[:value].val)]
    end

    def process_recmethod(node)
      [:recmethod, node[:name].val, process(node[:value].val)]
    end

    ## Assignment
    def process_assign(node)
      [:assign, node[:name].val, process(node[:value].val)]
    end

    ## Variables
    def process_var(node)
      [:var, node[:name].val]
    end

    ## Access/methods
    def process_access(node)
      [:access, process(node[:base].val), node[:name].val]
    end

    def process_method(node)
      [:method, process(node[:base].val), node[:name].val, []]
    end

    def process_call(node)
      if node[:args]
        args = process(node[:args].val)
      else
        args = []
      end

      expr = process(node[:expr].val)

      if expr[0] == :method
        expr[3].concat args
        expr
      else
        [:call, expr, args]
      end
    end

    def process_arg(node)
      rest = process(node[:rest].val) if node[:rest]
      [*rest, process(node[:value].val)]
    end
  end
end

