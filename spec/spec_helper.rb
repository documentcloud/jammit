# encoding: utf-8
$TESTING=true

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))
require 'jammit'

require 'rubygems'
require 'rack'

Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

RSpec.configure do |config|
  config.include(Jammit::Spec::Helpers)
  # config.include(Warden::Test::Helpers)

  # def load_strategies
  #   Dir[File.join(File.dirname(__FILE__), "helpers", "strategies", "**/*.rb")].each do |f|
  #     load f
  #   end
  # end
end

def test_html_head(body, tag, keys)
  html = Nokogiri::HTML(body)
  html.css("head #{tag}").text.should == keys 
end

def test_html_head_script(body, str)
  html = Nokogiri::HTML(body)
  script = html.at_css("script")
  script.attributes.first.last.text.should == str
end
