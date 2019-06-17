require 'spec_helper'

describe Parliament::Parliamentarian do
  let(:pending_data) { JSON.parse(File.read(File.join('spec', 'fixtures', 'pending.json'))) }
  let(:success_data) { JSON.parse(File.read(File.join('spec', 'fixtures', 'success.json'))) }
  let(:pr_hash) { JSON.parse(File.read(File.join('spec', 'fixtures', 'pr_hash.json'))) }
  let(:client) { double('client', pulls: [pr_hash]) }
  let(:parliamentarian) { Parliament::Parliamentarian.new(client) }

  before(:each) do
    Parliament.reset_configuration
  end

  context 'with success status update' do
    context '#process' do
      it 'merges the pr' do
        pr = double(:pull_request, merged?: true, merge: true, mergeable?: true)
        expect(parliamentarian).to receive(:pr_from_status_update).and_return(pr)
        parliamentarian.process(success_data)
      end
    end
  end
end
