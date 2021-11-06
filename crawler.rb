require 'bundler/setup'
require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require_relative 'formatter'

class Crawler
  attr_reader :scheme, :host
  attr_accessor :pages

  def initialize(url)
    @to_visit = []
    @pages = {}
    valid_url?(url)
  end

  def new_request
    Faraday.new(url: "#{scheme}://#{host}") do |f|
      f.request :retry # retry transient failures
      f.response :follow_redirects
      f.ssl[:verify] = true
    end
  end

  def fetch_next_page(http, path)
    http.get(path)
  end

  def crawl
    until to_visit.empty?
      path = to_visit.pop
      document = fetch_next_page(new_request, path) if path
      scrape(document.body, path) if document
    end
  end

  def export_json
    Formatter.new("Site data for #{host}", pages)
  end

  private

  attr_accessor :to_visit, :page_links

  def scrape(document, path)
    document = Nokogiri::HTML(document)
    all_links = get_links(document)
    update_to_visit(all_links)
    pages[path] = assets_on_page(document)
  end

  def valid_url?(url)
    response = Faraday.get(url)
    return initial_state(url) if response.status == 200
  rescue StandardError
    puts 'Please enter a complete URL (example: https://www.websitename.com/).'
    puts 'If the error persists, please verify site is running.'
  end

  def initial_state(url)
    uri = URI(url)
    @scheme = uri.scheme
    @host = uri.host
    to_visit << '/'
  end

  def domain_string
    "#{scheme}://#{host}"
  end

  def get_links(document)
    all_links = get_elements(document.css('a'), 'href')
    @page_links = all_links.select { |l| URI(l).scheme && URI(l).host }
                           .compact
                           .map(&:strip)
                           .uniq
                           .reject { |l| l == '' }
    all_links
  end

  def assets_on_page(page)
    css = get_elements(page.css('link'), 'href')
    scripts = get_elements(page.css('script'), 'src')
    images = get_elements(page.css('img'), 'src')
    { "Links:": page_links,
      "Assets": {
        "CSS:": css,
        "SCRIPTS:": scripts,
        "IMAGES:": images
      } }
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
      next if potential_path.nil?

      if (link.host == host || link.instance_of?(URI::Generic)) && unvisited(potential_path)
        to_visit << potential_path
        pages[potential_path] ||= {}
      end
    end
  end

  def unvisited(potential_path)
    !pages[potential_path] &&
      potential_path.length > 1 &&
      !pages.keys.include?(potential_path[0..-2])
  end
end
 