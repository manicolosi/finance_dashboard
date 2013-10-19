require_relative '../lib/gnucash'
require_relative '../lib/dropbox_downloader'

SCHEDULER.every '5m' do
  data = DropboxDownloader.get_file("/Finance/GnuCash/Finances.gnucash")
  book = Gnucash::Book.new(data)

  update_asset_balance("house-fund", book.account_by_name("Savings Account"))
  update_asset_balance("checking-account", book.account_by_name("Checking Account"))
end

def update_asset_balance(data_id, account)
  @balances ||= {}
  last_balance = @balances[data_id]
  balance = account.balance

  if balance != last_balance
    send_event(data_id, { current: balance, last: last_balance })
  end

  @balances[data_id] = balance
end
