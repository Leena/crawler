require 'faraday'
require 'faraday_middleware'
require 'uri'
require "nokogiri"
require_relative "formatter"

class Crawler
  attr_reader :scheme, :host

  def initialize(url)
    @to_visit = []
    @pages = {}
    @path = ''
    valid_url?(url)
  end

  def new_request
    conn = Faraday.new(url: scheme + "://" + host) do |f|
      f.request :retry # retry transient failures
      f.response :follow_redirects 
      f.ssl[:verify] = true
    end
  end

  def fetch_next_page(http, path)
    response = http.get(path)
  end

  def crawl 
    until @to_visit.empty?
      path = @to_visit.pop
      document = fetch_next_page(new_request, path) if path
      scrape(document.body, path)
    end
  end

  def export_JSON
     Formatter.new("skdfhkdshf for #{host}", @pages) 
  end

 private

 def scrape(document, path)
  document = Nokogiri::HTML(document)
  all_links = get_links(document)
  update_to_visit(all_links)
  @pages[path] = assets_on_page(document)
end

  def valid_url?(url)
    begin
      response = Faraday.get(url)
      if response.status === 200
        return set_initial_state(url)
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
    @to_visit << '/'
  end

  def domain_string
    return if path.nil?
    scheme + "://" + host
  end

  def get_links(document)
    all_links = get_elements(document.css("a"), "href")
    @links = all_links.select {|l| URI(l).scheme && URI(l).host}
    .compact
    .map { |l| l.strip }
    .uniq
    .reject { |l| l == '' }
    all_links
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
      potential_path = link.path
      next if potential_path == nil
      if (link.host == host || link.class == URI::Generic) && unvisited(potential_path)
        @to_visit << potential_path  
        @pages[potential_path] ||= {}
      end
    end
  end

  def unvisited(potential_path)
    !@pages[potential_path] && 
    potential_path.length > 1 && 
    !@pages.keys.include?(potential_path[0..-2])
  end
end

crawler_test_2 = Crawler.new("https://sedna.com/")
crawler_test_2.crawl
crawler_test_2.export_JSON