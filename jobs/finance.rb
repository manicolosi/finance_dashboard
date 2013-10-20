require_relative '../lib/gnucash'
require_relative '../lib/dropbox_downloader'

SCHEDULER.every '1m', :first_in => 0 do
  print "Starting"

  data = DropboxDownloader.get_file("/Finance/GnuCash/Finances.gnucash")
  book = Gnucash::Book.new(data)

  AssetBalanceUpdater.call("checking", book.account_by_name("Checking"))
  AssetBalanceUpdater.call("emergency-savings", book.account_by_name("Emergency Savings"))
  AssetBalanceUpdater.call("house-savings", book.account_by_name("House Savings"))
  AssetBalanceUpdater.call("mark-cbl-savings", book.account_by_name("Mark's CBL Savings"))

  ExpenseUpdater.call("expenses-groceries", book.account_by_name("Groceries"))
  ExpenseUpdater.call("expenses-gas", book.account_by_name("Gas"))

  puts "... finished"
end

class Updater
  def self.balances
    @balances ||= {}
  end
end

class ExpenseUpdater < Updater
  def self.call(data_id, account)
    balance = account.transactions_since(beginning_of_month).balance / 100.0
    last_balance = balances[data_id]

    if balance != last_balance
      send_event(data_id, current: balance,
                          last: last_balance,
                          moreinfo: more_info,
                          title: account.name)
    end

    balances[data_id] = balance
  end

  def self.more_info
    moreinfo = "Spent in #{current_month_name}. Budget is $#{budget}"
  end

  def self.budget
    rand(50) * 10
  end

  def self.current_month_name
    beginning_of_month.strftime("%B")
  end

  def self.beginning_of_month
    today = Date.today
    Date.new(today.year, today.month)
  end
end

class AssetBalanceUpdater < Updater
  def self.call(data_id, account)
    last_balance = balances[data_id]
    balance = account.balance / 100.0

    if balance != last_balance
      send_event(data_id, current: balance,
                          last: last_balance,
                          moreinfo: more_info,
                          title: account.name)
    end

    balances[data_id] = balance
  end

  def self.more_info
    "Goal: $#{goal}K"
  end

  def self.goal
    rand(10)
  end
end

