current_valuation = 0

SCHEDULER.every '5s' do
  update_asset_balance("house-fund", "Savings Account")
  update_asset_balance("checking-account", "Checking Account")
end

def update_asset_balance(data_id, asset_name)
  @balances ||= {}
  last_balance = @balances[data_id]
  balance = get_asset_balance(asset_name)

  if balance != last_balance
    send_event(data_id, { current: balance, last: last_balance })
  end

  @balances[data_id] = balance
end

# TODO: Download file from Dropbox if it doesn't exist. Cache for a period of
# time, so it's re-used until the scheduler updates.
def get_asset_balance(asset_name)
  tmpfile = `mktemp`.chomp
  `zcat Finances.gnucash > #{tmpfile}`
  `ledger -n -f #{tmpfile} balance "Assets:Current Assets:#{asset_name}"`.gsub(/[^0-9.]/,'')
end
