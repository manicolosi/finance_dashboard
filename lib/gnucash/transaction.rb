module Gnucash
  class Transaction
    attr_reader :node

    def initialize(reference_account, node)
      @reference_account = reference_account
      @node = node
    end

    def id
      @node.xpath('trn:id').text
    end

    def date_posted
      Date.parse(@node.xpath('trn:date-posted').text.strip)
    end

    def inspect
      %{<Gnucash::Transaction description="#{description}" id="#{id}" date_posted="#{date_posted}">}
    end

    def description
      @node.xpath('trn:description').text
    end

    def reference_split
      @node.xpath('trn:splits/trn:split').find do |split|
        split_account_id(split) == @reference_account.id
      end
    end

    def value
      reference_split.xpath('split:value').text.gsub(/\/100$/, '').to_i
    end

    def split_account_id(split_node)
      split_node.xpath('split:account').text
    end
  end
end
