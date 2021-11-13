# Web Crawler 
### Overview
This web crawler will visit all links contained within a domain. For each page, it will retrieve all links and assets such as images and files and generate the site map. It can generate a `JSON` file containing results. 

Please see the [example_output](https://github.com/Leena/web_crawler/tree/master/example_output) folder for pre-fetched results. 

###  Pre-requisites 
1. [Ruby](https://www.ruby-lang.org/en/downloads/) version 2.7 or higher
2. [Ruby Gems](https://rubygems.org/pages/download)
3. [Bundler](https://bundler.io/)

### Installation
1. Clone this repository
2. Run `bundle install` to install all required gems and dependencies

### Usage
In the `crawler.rb` file, enter the domain you wish to craw as: `crawler = Crawler.new('https://domain.com/')`. 

Next, to being crawling, call `crawl` on your crawler object: `crawler.crawl`. 

To generate a JSON file with the results, call `export_json`: `crawler.export_json`.

To recap, enter these 3 lines at the bottom of the file: 
```ruby
crawler = Crawler.new('https://domain.com/')
crawler.crawl
crawler.export_json
```

When ready, enter `ruby crawler.rb` at your terminal to start the process. 

### Tests
Run `ruby crawler_test.rb` to view results.

### Notes 
There are performance issues for larger sites. The crawler does not leverage threading yet. 

### Design Choices
1. Politeness is not verified
2. HTTP/S is the only protocol supported 
3. Redirects are followed

### Future Work
- [ ] Implement threading for multiple network calls and improved performance.
- [ ] Implement politeness setting 
