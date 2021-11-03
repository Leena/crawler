require 'faraday'
require 'uri'
require "nokogiri"
require_relative "formatter"

class Crawler
  attr_reader :scheme, :host
  attr_accessor :path, :paths_to_visit, :pages, :links

  def initialize(url)
    valid_url?(url)
    @paths_to_visit = []
    @pages = {}
  end

  def crawl 
    scrape_first_page(next_url)
 
    # until paths_to_visit.empty?
    #   fetch_queue = Queue.new
    #   threads = []
    #   100.times do 
    #     threads << Thread.new do
    #       path = paths_to_visit.pop
    #       fetch_queue << Faraday.get(next_url) if path != nil 
    #     end
    #   end
    #   threads.each(&:join)
    #   fetch_queue.length.times do 
    #     document = Faraday.get(next_url)
    #     scrape(document.body)
    #   end
    #  end
  end

  def scrape_first_page(page)
    document = Faraday.get(page)
    scrape(document.body)
  end 


  def scrape(document)
    document = Nokogiri::HTML(document)
    links = get_links(document)
    update_to_visit(links)
    pages[path] = assets_on_page(document)
  end

  def export_JSON
   Formatter.new("Crawled Data for #{host}", pages) 
  end

  private

  def valid_url?(url)
    begin
      response = Faraday.get(url)
        if response.status === 200
          set_initial_state(url)
          true
        end
    rescue 
      puts 'Please enter a complete URL, for example:'
      puts 'https://www.websitename.com/'
      puts 'If the error persists, please verify site is running.'
    end
  end  

  def set_initial_state(url)
    uri = URI(url)
    @scheme = uri.scheme
    @host = uri.host
    @path = '/'
  end

  def next_url 
    scheme + "://" + host + path
  end

  def get_links(document)
   # some of these links start with / and are still local even if they do not have the domain associated to it! This should be considered as a path and added to the path list. 
   links = get_elements(document.css("a"), "href")
   @links = links.select { |l| URI(l).scheme && URI(l).host}
  #  .compact
  #  .map { |l| l.strip }
  #  .uniq
  #  .reject { |l| l == ''}
   end

  def assets_on_page(page)
    css = get_elements(page.css("link"), "href")
    scripts = get_elements(page.css("script"), "src")
    images = get_elements(page.css("img"), "src")

    { 
     "Links:": @links,
     "Assets": {
        "CSS:": css, 
        "SCRIPTS:": scripts, 
        "IMAGES:": images
      }
    }
  end

  def get_elements(element, attribute)
    element.map { |e| e.attributes[attribute] && e.attributes[attribute].value }
    .compact
    .uniq
  end

  def update_to_visit(links)
    links.each do |link|
      link = URI(link)
      if link.host == host && !pages[link.path] 
        paths_to_visit << link.path
      end
    end
  end


end

  #  crawler_test_1 = Crawler.new("https://leenalallmon.com") 
  #  crawler_test_1.crawl
  #  crawler_test_1.export_JSON


  crawler_test_2 = Crawler.new("https://danicos.me")
  crawler_test_2.crawl
  # crawler_test_2.export_JSON

