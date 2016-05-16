require 'open-uri'
require 'nokogiri'
require 'zip'
require 'byebug'

module NewsXml
  class FileNames < Array
    attr_reader :base_uri

    def initialize(url = 'http://bitly.com/nuvi-plz')
      @url = url
    end

    def fetch_data
      self.concat fetch_names
      print "Found around #{self.count} files.\n"
      self
    end

    private

    def fetch_names
      print "Getting files name from #{@url}.\n"
      open_url = open @url
      @base_uri = open_url.base_uri
      @html = Nokogiri::HTML(open_url)
      find_file_names
    end

    def find_file_names
      @html.css('td a').map {|link| link['href'] }.select{|name| name =~ /\.zip/ }
    end
  end
end