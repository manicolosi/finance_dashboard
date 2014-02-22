require 'zlib'
require 'nokogiri'

require_relative 'account'

module Gnucash
  class Book
    attr_reader :xml

    def initialize(reader)
      reader = Zlib::GzipReader.new(reader)
      @xml = Nokogiri.XML(reader.read)
    end

    def book
      @xml.xpath('/gnc-v2/gnc:book')
    end

    def accounts
      book.xpath('gnc:account')
    end

    def account_by_name(name)
      account_node = accounts.find { |a| a.xpath('act:name').text == name }
      Account.new(self, account_node)
    end

    def account_by_id(id)
      account_node = accounts.find { |a| a.xpath('act:id').text == id }
      Account.new(self, account_node)
    end

    def accounts_by_parent_id(id)
      account_nodes = accounts.select { |a| a.xpath('act:parent').text == id }
      account_nodes.map { |node| Account.new(self, node) }
    end

    def transactions
      book.xpath('gnc:transaction')
    end
  end
end
