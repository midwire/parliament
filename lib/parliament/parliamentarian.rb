# frozen_string_literal: true

require 'octokit'

module Parliament
  class Parliamentarian
    def initialize(client = Parliament.client)
      @logger = Logger.new('log/parliamentarian.log', 'daily')
      @client = client
    end

    def process(data)
      @status_update = StatusUpdate.new(data)
      return nil unless @status_update.success?

      @pull_request = pr_from_status_update(@status_update)
      return nil unless @pull_request.mergeable?

      if ok_to_merge?(@pull_request, data)
        @logger.info('Ok to merge')
        @pull_request.merge
        # TODO: Delete the branch
      else
        @logger.info('Not ok to merge')
      end
    end

    def required_usernames(data)
      required = Parliament.configuration.required_usernames
      if required.respond_to?(:call)
        required.call(data)
      else
        required
      end
    end

    def required_contexts(data)
      required = Parliament.configuration.required_contexts
      if required.respond_to?(:call)
        required.call(data)
      else
        required
      end
    end

    private

    # The question here is do we rely on the GitHub account to determine if the PR
    # is mergeable or do we allow parliament configuration to determine when it is OK
    # to merge?
    def ok_to_merge?(pull_request, data)
      pull_request.mergeable?
      # status_ok?(pull_request) &&
      #   required_users_ok?(pull_request, data) &&
      #   score_ok?(pull_request)
    end

    def status_ok?(pull_request)
      if Parliament.configuration.check_status
        pull_request.state == 'success'
      else
        true
      end
    end

    def required_users_ok?(pull_request, data)
      pull_request.approved_by?(required_usernames(data))
    end

    def score_ok?(pull_request)
      pull_request.score >= Parliament.configuration.threshold
    end

    def log_comment(comment)
      @logger.info("Comment: '#{comment['body']}' from '#{comment['user']['login']}'")
    end

    def pr_from_status_update(status_update)
      pr_hash = @client.pulls(status_update.repository, state: :open).find do |pr|
        pr['head']['sha'] == status_update.sha
      end
      return nil unless pr_hash.any?

      PullRequest.new(pr_hash)
    end
  end
end
