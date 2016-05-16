require 'net/http/persistent'
require './src/news_xml//file_names'
require './src/news_xml/store'
require './src/news_xml/parser'

module NewsXml
  class Worker
    DOWNLOAD_FOLDER = 'tmp/'

    def initialize(concurrency)
      @queue = Queue.new
      @downloaded_th = Queue.new
      @store_th = []
      @concurrency = concurrency
      @file_names = FileNames.new
      @semaphore = Mutex.new
      @processed = 0 
    end

    def run
      @file_names.fetch_data
      @file_names.map {|file_name| @queue << file_name}
      @uri = @file_names.base_uri
      FileUtils.rm_rf("#{DOWNLOAD_FOLDER}.", secure: true)
      run_downloaders
      run_storers
    end

    private

    def run_downloaders
      concurrent do
        http = Net::HTTP::Persistent.new 'news_xml'
        while !@queue.empty? && name = @queue.pop
          @downloaded_th << donwload(http, name)
        end
      end
    end

    def run_storers
      @store_th = concurrent do
        store = Store.new
        parser = NewsParser.new
        while name = @downloaded_th.pop
          posts = parser.posts("#{DOWNLOAD_FOLDER}#{name}")
          store.concat_to_list posts, name
          @semaphore.synchronize do
          incr_processed 
          if @processed == @file_names.size
            print "processed #{@processed} \n"
            exit
          end
        end
        end
      end
      @store_th.each(&:join)
    end

    def donwload(http, name)
      uri = URI "#{@uri}#{name}"
      print "start to download #{uri} ...\n"
      begin
        response = http.request(uri).body
      rescue
        print "error while download"
        incr_processed 
      end
      File.open("#{DOWNLOAD_FOLDER}#{name}", 'wb') do |fo|
        fo.write(response)
      end
      print "download #{uri} completed. \n"
      name
    end

    def incr_processed; @processed += 1 end

    def concurrent(&block)
      @concurrency.times.map do
        Thread.new do
          yield
        end
      end
    end
  end
end
