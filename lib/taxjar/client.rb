require "faraday"
require 'faraday_middleware'
Dir[File.expand_path('../../faraday/*.rb', __FILE__)].each{|f| require f}

module Taxjar
  class Client

    attr_accessor *Configuration::VALID_CONFIG_KEYS
    attr_reader :conn

    def initialize(options={})
      options = Taxjar.options.merge(options)

      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", options[key])
      end

      setup_conn
    end

    def sales_tax(options={})
      response = @conn.get "/sales_tax", options
      response.body
    end

    def tax_rate(options={})
      response = @conn.get "/locations/#{options.delete(:zip)}", options
      response.body
    end

    private

    def setup_conn
      options = {
        :headers => {'Accept' => "application/#{format}; charset=utf-8", 'User-Agent' => user_agent},
        :proxy => proxy,
        :url => endpoint,
      }.merge(connection_options)

      @conn = Faraday::Connection.new(options) do |c|
        c.token_auth self.auth_token
        c.use FaradayMiddleware::ParseJson
        c.use FaradayMiddleware::RaiseHttpException
        c.adapter(adapter)
      end

    end
  end
end