# encoding: utf-8
require 'spec_helper'

describe Jammit::Controller do

  def basic_app
    lambda { |e| [200, {'Content-Type' => 'text/plain'}, '<h1>FunkyBoss</h1>'] }
  end

  it "inserts Jammit into the rack env" do
    env = env_with_params
    setup_rack(basic_app).call(env)
    env["jammit"].should be_an_instance_of(Jammit::Controller)
  end

  describe "serves assets" do
    it "responds with 200" do
      env = env_with_params("/assets/app.js", {})
      result = setup_rack(basic_app).call(env)
      result.last.should == ['var Foo = 1']
    end
  end
end
