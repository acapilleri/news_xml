module NewsXml
  class NewsParser
    def posts(path)
      @path = path 
      @post = []
      @count_files = 0
      uncompress
    end

    def uncompress
      Zip::File.open(@path) do |zip_file|
        print "Uncompressing #{@path} and parse files...\n"
        zip_file.each_with_index do |entry, index|
          @post << parse_file(entry.get_input_stream.read)
        end
      end
      print "Uncompressing #{@path} files...\n"
      @post.uniq {|post| post[0] }
    end

    def parse_file(content)
      xml = Nokogiri::XML content
      post_id = xml.xpath("//post_id").children.text
      [post_id, xml.to_s]
    end
  end
end