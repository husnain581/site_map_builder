require 'open-uri'
require 'nokogiri'

class Sitemap
  def initialize
    @siteslinks = []
    for arg in ARGV
      @root_url = arg
    end
    puts "Please wait..."
  end

  def builder
    links_reader(@root_url)

    @siteslinks.each do |link_address|
      links_reader(link_address)
    end

    xml_creator
  end


  def links_reader(url)
    begin
      if url.start_with?('/')
        url = @root_url + url
      end
      page = Nokogiri::HTML(URI.open(URI::Parser.new.escape(url)))
      link_extractor(page)
    rescue StandardError => e
      puts "Could not parse URL: #{url} due to #{e.message}"
      return
    end
  end

  def link_extractor(page)
    page.css('a').each do |a_tag|
      unless @siteslinks.any?(a_tag['href'])
       @siteslinks.push(a_tag['href']) if a_tag['href']&.start_with?('/',@root_url)
     end
   end
  end

  def xml_creator
    xml = Nokogiri::XML::Builder.new { |xml|
      xml.body do
        @siteslinks.each do |link|
          xml.url do
            xml.loc link
          end
        end
      end
    }.to_xml

    puts xml
  end

end

@sitemapbuilder = Sitemap.new
@sitemapbuilder.builder

