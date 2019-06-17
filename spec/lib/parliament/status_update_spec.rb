# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Parliament::StatusUpdate do
  let(:pending_data) { JSON.parse(File.read(File.join('spec', 'fixtures', 'pending.json'))) }
  let(:success_data) { JSON.parse(File.read(File.join('spec', 'fixtures', 'success.json'))) }
  let(:status_update) { StatusUpdate.new(success_data) }

  it 'has a sha' do
    expect(status_update.sha).to_not be_nil
  end

  it 'has a state' do
    expect(status_update.state).to eq('success')
  end

  it 'has a repository' do
    expect(status_update.repository).to eq('midwire/parliament_test')
  end
end
