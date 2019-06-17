# frozen_string_literal: true

require 'logger'

require 'dotenv/load'
require 'pry' if ENV.fetch('DEBUG') { false }
require 'parliament/status_update'
require 'parliament/pull_request'
require 'parliament/parliamentarian'
require 'parliament/server'
require 'parliament/version'

module Parliament
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration
    @configuration = Configuration.new
  end

  def self.client
    @client ||= Octokit::Client.new(access_token: Parliament.configuration.personal_access_token)
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :threshold
    attr_accessor :check_status
    attr_accessor :required_usernames
    attr_accessor :required_contexts
    attr_accessor :personal_access_token

    def initialize
      @threshold = 3
      @check_status = true
      @required_usernames = []
      @required_contexts = []
      @personal_access_token = ENV.fetch('GITHUB_PA_TOKEN') { nil }
    end
  end
end

include Parliament
