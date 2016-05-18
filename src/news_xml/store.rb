require "redis"

module NewsXml
   class Store
     HOST = 'localhost'
     PORT = 6379
     DB = 15
     LIST_NAME = 'NEWS_XML'
     SET = 'news_set'

     def initialize
       @redis = Redis.new(host: HOST, :port => PORT, :db => DB)
     end

     def concat_to_list posts, name 
       print "try Store [#{posts.count}] posts of #{name}\n"
       posts.each do |post|
         id = post[0]
         if @redis.sadd SET, id
           print "Stored posts id: #{id}\n"
           @redis.rpush LIST_NAME, post[1]
         end
       end
     end 
   end
end