require_relative '../lib/gnucash'
require_relative '../lib/dropbox_downloader'
require 'debugger'

SCHEDULER.every '5m', :first_in => 0 do
  data = DropboxDownloader.get_file("/Finance/GnuCash/Gnucash2014.gnucash")
  book = Gnucash::Book.new(data)

  #expenses = book.account_by_name 'Expenses'
  #groceries = book.account_by_name 'Groceries'
  #debugger

  AssetBalanceUpdater.call("checking", book.account_by_name("Checking"))
  AssetBalanceUpdater.call("savings", book.account_by_name("Savings"))

  items = book.account_by_name('Expenses').children.map do |expense|
    expense_item(expense)
  end.sort_by { |i| i[:value][1..-1].to_i }.reverse

  send_event('monthly-spending',
             moreinfo: "Spending in #{current_month_name}",
             items: items)
end

def expense_item(account)
  value = account.transactions_since(beginning_of_month).balance || 0

  { label: account.pretty_full_name, value: "$#{value / 100}" }
end

def self.current_month_name
  beginning_of_month.strftime("%B")
end

def self.beginning_of_month
  today = Date.today
  Date.new(today.year, today.month)
end

class Updater
  def self.balances
    @balances ||= {}
  end
end

class AssetBalanceUpdater < Updater
  def self.call(data_id, account)
    last_balance = balances[data_id]
    balance = account.balance / 100

    if balance != last_balance
      send_event(data_id, current: balance,
                          last: last_balance,
                          title: account.name)
    end

    balances[data_id] = balance
  end
end
