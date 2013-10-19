module Gnucash
  class Account
    attr_reader :node
    attr_reader :name, :guid, :type

    def initialize(book, node)
      @book = book
      @node = node
      @name = node.xpath('act:name').text
      @guid = node.xpath('act:id').text
      @type = node.xpath('act:type').text.downcase
    end

    def inspect
      %{<Gnucash::Account name="#@name" guid="#@guid" type="#@type">}
    end

    def transactions
      @book.transactions.select do |transaction|
        transaction_splits_account_ids(transaction).any? { |acc_id| acc_id == guid }
      end
    end

    def splits
      transactions.flat_map do |tr|
        tr.xpath('trn:splits/trn:split').select { |split| split.xpath('split:account').text == guid }
      end
    end

    def split_value(split)
      split.xpath('split:value').text.gsub(/\/100$/, '').to_i
    end

    def balance
      splits.map { |split| split_value(split) }
            .reduce(&:+) / 100.0
    end

    def transaction_splits_account_ids(transaction_node)
      transaction_node.xpath('trn:splits/trn:split/split:account').map(&:text)
    end
  end
end
