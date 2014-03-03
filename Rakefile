# From: http://erniemiller.org/2014/02/05/7-lines-every-gems-rakefile-should-have
task :console do
  require 'irb'
  require 'irb/completion'
  require_relative 'lib/gnucash'
  require_relative 'lib/dropbox_downloader'
  ARGV.clear
  IRB.start
end
