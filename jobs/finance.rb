require_relative '../lib/gnucash'
require_relative '../lib/dropbox_downloader'

SCHEDULER.every '5m' do
  data = DropboxDownloader.get_file("/Finance/GnuCash/Finances.gnucash")
  book = Gnucash::Book.new(data)

  update_asset_balance("checking", book.account_by_name("Checking"))
  update_asset_balance("emergency-savings", book.account_by_name("Emergency Savings"))
  update_asset_balance("house-savings", book.account_by_name("House Savings"))
  update_asset_balance("mark-cbl-savings", book.account_by_name("Mark's CBL Savings"))
end

def update_asset_balance(data_id, account)
  @balances ||= {}
  last_balance = @balances[data_id]
  balance = account.balance

  if balance != last_balance
    send_event(data_id, current: balance,
                        last: last_balance,
                        moreinfo: "Goal: #{rand(10)}K",
                        title: account.name)
  end

  @balances[data_id] = balance
end
