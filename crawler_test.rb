require 'minitest/autorun'
require_relative 'crawler'

class CrawlerTest < Minitest::Test

  def test_valid_url_state
    url = 'https://techcrunch.com'
    crawler = Crawler.new(url)
    domain_string = "#{crawler.scheme}://#{crawler.host}"
    assert_equal(domain_string, url)
  end

  def test_invalid_url
    url = 'invalidurl'
    crawler = Crawler.new(url)
    assert_nil(crawler.host, nil)
    assert_output(/Please enter a complete URL/) {Crawler.new(url)}
  end

  def test_network_call
    url = 'https://techcrunch.com'
    crawler = Crawler.new(url) 
    page_request = crawler.new_request
    assert_instance_of(Faraday::Connection, page_request)
  end

  def test_pages_contain_data
    url = 'https://example.com/'
    crawler = Crawler.new(url) 
    crawler.crawl
    refute_empty(crawler.pages)
  end
  
end