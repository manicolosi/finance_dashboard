require_relative 'transaction_group'

module Gnucash
  class Account
    attr_reader :node

    def initialize(book, node)
      @book = book
      @node = node
    end

    def inspect
      %{<Gnucash::Account name="#{name}" id="#{id}" type="#{type}">}
    end

    def name
      @name ||= @node.xpath('act:name').text
    end

    def parent
      @parent ||= @book.account_by_id(parent_id) if parent_id
    end

    def ancestors
      @ancestors ||= [parent] + parent.ancestors.to_a if parent
    end

    def full_name
      @full_name ||= ([self] + ancestors).map(&:name).reverse
    end

    def pretty_full_name(cut_off = 0)
      full_name[cut_off..-1].join('::')
    end

    def parent_id
      @parent_id ||= @node.xpath('act:parent').text
      @parent_id unless @parent_id.empty?
    end

    def id
      @id ||= @node.xpath('act:id').text
    end

    def children
      @children ||= @book.accounts_by_parent_id id
    end

    def descendants
      @descendants ||= children.map do |acc|
        [acc] + acc.descendants
      end.flatten
    end

    def type
      @type ||= @node.xpath('act:type').text
    end

    def transaction_nodes
      @book.transactions.select do |transaction|
        transaction_splits_account_ids(transaction).any? { |acc_id| acc_id == id }
      end
    end

    def transactions
      TransactionGroup.new self, transaction_nodes
    end

    def transactions_since(date)
      TransactionGroup.new self, transactions.select { |trn| trn.date_posted >= date }
    end

    def balance
      transactions.map(&:value).reduce(&:+)
    end

    def transaction_splits_account_ids(transaction_node)
      transaction_node.xpath('trn:splits/trn:split/split:account').map(&:text)
    end
  end
end
