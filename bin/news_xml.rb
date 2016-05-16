require './src/news_xml/worker'

concurrency = ARGV[0].to_i || 10 # how many downloaders
NewsXml::Worker.new(concurrency).run