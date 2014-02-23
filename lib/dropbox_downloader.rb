require 'dropbox_sdk'

module DropboxDownloader
  ACCESS_TOKEN = ENV['DROPBOX_TOKEN']

  def self.file_and_metadata(name)
    client.get_file_and_metadata(name)
  end

  def self.client
    DropboxClient.new(ACCESS_TOKEN)
  end
end
