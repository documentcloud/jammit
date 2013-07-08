# encoding: utf-8
module Jammit::Spec
  module Helpers
    def env_with_params(path = "/", params = {}, env = {})
      method = params.delete(:method) || "GET"
      env = { 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => "#{method}" }.merge(env)
      Rack::MockRequest.env_for("#{path}?#{Rack::Utils.build_query(params)}", env)
    end

    def setup_rack(app = basic_app, opts = {}, &block)
      app ||= block if block_given?

      Rack::Builder.new do
        use Jammit::Controller, opts
        run app
      end
    end

  end
end
