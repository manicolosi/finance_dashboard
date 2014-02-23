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
      @accounts ||= book.xpath('gnc:account').map { |node| Account.new(self, node) }
    end

    def account_by_name(name)
      accounts.find { |a| a.name == name }
    end

    def account_by_id(id)
      accounts.find { |a| a.id == id }
    end

    def accounts_by_parent_id(id)
      accounts.select { |a| a.parent_id == id }
    end

    def transactions
      book.xpath('gnc:transaction')
    end
  end
end
