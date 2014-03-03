require_relative '../lib/gnucash'
require_relative '../lib/dropbox_downloader'
require 'debugger'
require 'benchmark'
require 'dashing'

GNUCASH_FILE = "/Finance/GnuCash/Gnucash2014.gnucash"

SCHEDULER.every '5m', :first_in => 0 do
  print "Updating... "

  contents, metadata = DropboxDownloader.file_and_metadata(GNUCASH_FILE)

  time = Benchmark.realtime do
    rev = metadata['rev']

    if rev != @last_rev
      @last_rev = rev
      book = Gnucash::Book.new(contents)

      AssetBalanceUpdater.call("checking", book.account_by_name("Checking"))
      AssetBalanceUpdater.call("savings", book.account_by_name("Savings"))
      AssetBalanceUpdater.call("credit-card", book.account_by_name("Capital One Platinum"))

      expense_accounts = book.account_by_name('Expenses').descendants

      reject_parents = %w[Taxes Interest].map do |name|
        expense_accounts.find { |acc| acc.name == name }.id
      end

      items = expense_accounts
                .reject { |acc| reject_parents.include? acc.parent_id }
                .map { |acc| expense_item(acc) }
                .compact
                .sort_by { |exp| exp[:value] }
                .reverse
                .slice(0, 18)
                .sort_by { |exp| exp[:label] }

      send_event('monthly-spending',
                 title: "Spending in #{current_month_name}",
                 items: items)
    end
  end

  puts "%.3fs" % time
end

def expense_item(account)
  label = account.pretty_full_name(2)
  value = account.transactions_since(beginning_of_month).balance
  match = /^Budget: \$(\d+)$/.match(account.description)
  budget = match && match[1].to_i

  percentage = value / budget if budget

  if value != 0
    data = {
      label: label,
      value: value / 100,
      budget: budget,
    }

    if budget
      data.merge!( 
        percentage: percentage,
        is_over: percentage > 100,
        is_close: percentage > 90 && percentage <= 100,
        is_under: percentage <= 90
      )
    end
    data
  end
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
