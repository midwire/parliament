# frozen_string_literal: true

module Parliament
  class StatusUpdate
    attr_reader :sha
    attr_reader :state
    attr_reader :repository

    def initialize(data = {})
      @sha = data['sha']
      @state = data['state']
      @repository = data['repository']['full_name']
    end

    def success?
      @state.to_sym == :success
    end
  end
end
