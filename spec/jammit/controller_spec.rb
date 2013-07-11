# encoding: utf-8
require 'spec_helper'
require 'nokogiri'

describe Jammit::Controller do

  def test_html
    '<html>
        <head>
        <meta charset="utf-8">
        <title>test page</title>
        </head>
        <body><h1>FunkyBoss</h1></body>
    </html>'
  end

  def index_app
    lambda { |e| [200, {'Content-Type' => 'text/plain'}, test_html] }
  end

  it "inserts Jammit into the rack env" do
    env = env_with_params
    setup_rack(index_app).call(env)
    env["jammit"].should be_an_instance_of(Jammit::Controller)
  end

  describe "serving assets" do
    it "responds with" do
      env = env_with_params("/assets/app.js", {})
      result = setup_rack(index_app).call(env)
      result.last.should == ['var Foo = 1']
    end
  end

  describe "serving non-assets" do
    it "includes script tag" do
      env = env_with_params("/index.html", {})
      result = setup_rack(index_app).call(env)
      test_html_head(result.last, 'title', 'test page')
      test_html_head_attributes(result.last, 'meta', 'charset=utf-8')
    end
  end

end
