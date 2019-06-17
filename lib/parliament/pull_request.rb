# frozen_string_literal: true

require 'github/markdown'

module Parliament
  class PullRequest
    attr_reader :label
    attr_reader :merged_at
    attr_reader :number
    attr_reader :repo_name
    attr_reader :state

    def initialize(data = {})
      @number = data['number']
      @state = data['state']
      @repo_name = data['head']['repo']['full_name']
      @label = data['head']['label']
      @logger = Logger.new('log/parliamentarian.log', 'daily')
    end

    def merged?
      !merged_at.nil?
    end

    def merge(client = Parliament.client)
      return nil unless mergeable?

      @logger.info("Merging Pull Request: #{@number} on #{@label}")
      client.merge_pull_request(@repo_name, @number, '')
    end

    def mergeable?
      return false if merged?
      return false unless state.to_sym == :open

      true
    end
  end
end
