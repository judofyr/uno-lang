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

    def process_num(node)
      [:integer, node[:value].val.to_i]
    end
  end
end

