require 'dropbox_sdk'
require 'stringio'

module DropboxDownloader
  ACCESS_TOKEN = ENV['DROPBOX_TOKEN']

  def self.get_file(name)
    StringIO.new client.get_file(name)
  end

  def self.client
    DropboxClient.new(ACCESS_TOKEN)
  end
end
