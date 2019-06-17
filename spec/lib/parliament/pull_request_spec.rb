# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
describe Parliament::PullRequest do
  # rubocop:enable Metrics/BlockLength
  let(:data) do
    path = File.join('spec', 'fixtures', 'pr_hash.json')
    JSON.parse(File.read(path))
  end
  let(:pull_request) { Parliament::PullRequest.new(data) }

  # leaving these here in case we want to handle plus/minus comments again
  let(:positive_comment) { '+1 I suppose we should merge this' }
  let(:fake_positive_comment) { '+ 1 I suppose we should merge this' }
  let(:positive_comment_struckthru) { "~~+1 awesome~~\nOops - nvm!" }
  let(:negative_comment) { '-1 This is a bad change.}' }
  let(:fake_negative_comment) { '- poop This is a bad change.' }
  let(:negative_comment_struckthru) { '~~-1 This is a bad change.~~}' }
  let(:negative_comment_struckthru_and_now_positive) { '~~-1 This is a bad change.~~Much better +1}' }
  let(:neutral_comment) { 'Who cares?' }
  let(:blocker_comment) { '[blocker] +1' }
  let(:blocker_comment_caps) { '[BLOCKER] +1' }
  let(:blocker_comment_struckthru) { '~~[blocker]~~' }

  context '#merged?' do
    it 'returns true if PR is already merged' do
      expect(pull_request).to_not be_merged
      expect(pull_request).to receive(:merged_at).and_return(Time.now.utc)
      expect(pull_request).to be_merged
    end
  end

  context '#merge' do
    it 'does not merge if already merged' do
      expect(pull_request).to receive(:merged?).and_return(true)
      expect(pull_request.merge).to eq(nil)
    end

    it 'does merge if not already merged' do
      expect(pull_request).to receive(:merged?).and_return(false)
      expect(Parliament.client).to receive(:merge_pull_request).and_return(true)
      expect(pull_request.merge).to eq(true)
    end
  end
end
