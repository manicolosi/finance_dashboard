require_relative 'transaction'

module Gnucash
  class TransactionGroup
    include Enumerable

    def initialize(reference_account, nodes)
      @reference_account = reference_account
      @nodes = nodes
    end

    def each
      @nodes.each do |node|
        if node.is_a? Transaction
          yield node
        else
          yield Transaction.new(@reference_account, node)
        end
      end
    end

    def balance
      map(&:value).reduce(&:+)
    end
  end
end
