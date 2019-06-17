# frozen_string_literal: true

require 'json'

module Parliament
  class Server
    OK_RESPONSE = [200, { 'Content-Type' => 'text/html' }, ['OK']].freeze
    NOT_FOUND_RESPONSE = [404, { 'Content-Type' => 'text/html' }, ['NOT FOUND']].freeze

    def initialize(parliament_service = Parliamentarian.new)
      @parliament_service = parliament_service
      @logger = Logger.new('log/parliamentarian.log', 'daily')
      @event_logger = Logger.new('log/events.log', 'daily')
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      if root_request(env)
        OK_RESPONSE
      elsif webhook_post_request(env)
        @logger.info("EventType: #{event_type(env)}")
        @parsed_data = nil
        handle_request(env)
        OK_RESPONSE
      else
        NOT_FOUND_RESPONSE
      end
    end

    private

    def root_request(env)
      /^\/?$/.match(env['PATH_INFO']) && env['REQUEST_METHOD'] == 'GET'
    end

    def webhook_post_request(env)
      /\/webhook/.match(env['PATH_INFO']) && env['REQUEST_METHOD'] == 'POST'
    end

    # Handle the request if it is a 'status' update
    def handle_request(env)
      log_request(env) if ENV['DEBUG']
      @parliament_service.process(parsed_data(env)) if event_type(env) == 'status'
    end

    def log_request(env)
      type = event_type(env)
      @event_logger.info("Event: (#{type}) [#{parsed_data(env)}]")
    end

    def parsed_data(env)
      @parsed_data ||= JSON.parse(data(env))
    end

    def data(env)
      content_type = env['CONTENT_TYPE']
      if content_type == 'application/x-www-form-urlencoded'
        Rack::Request.new(env).params['payload']
      elsif content_type == 'application/json'
        env['rack.input'].read
      else
        fail "Invalid request type #{content_type}"
      end
    end

    def event_type(env)
      env['HTTP_X_GITHUB_EVENT']
    end
  end
end
