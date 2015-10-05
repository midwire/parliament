describe Parliament::PullRequest do
  let(:data)         { Hashie::Mash.new(JSON.parse(File.read('spec/fixtures/issue.json'))) }
  let(:pull_request) { Parliament::PullRequest.new(data) }

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

  context '#comment_exists?' do
    it 'returns true if a comment exists' do
      expect(pull_request.comment_exists?).to eq(true)
    end

    it 'returns false if a comment does not exist' do
      data = Hashie::Mash.new(JSON.parse(File.read('spec/fixtures/issue.json')))
      data.comment = {}
      pull_request = Parliament::PullRequest.new(data)
      expect(pull_request.comment_exists?).to eq(false)
    end
  end

  context '#comment' do
    it 'returns the current comment' do
      comment = pull_request.comment
      comment.should be_a Hash
      expect(comment.body).to eq(data.comment.body)
    end
  end

  context 'single comment score' do
    it 'scores a +1 for comment with a plus sign followed by a number' do
      expect(
        pull_request.send(:comment_score, positive_comment) == 1
      ).to eq(true)
    end

    it 'scores a -1 for comment with a minus sign followed by a number' do
      expect(
        pull_request.send(:comment_score, negative_comment) == -1
      ).to eq(true)
    end

    it 'scores a 0 for comment with no +1 or -1' do
      expect(
        pull_request.send(:comment_score, neutral_comment) == 0
      ).to eq(true)
    end

    it 'scores a 0 for comment with a plus sign with no number following' do
      expect(
        pull_request.send(:comment_score, fake_positive_comment) == 0
      ).to eq(true)
    end

    it 'scores a 0 for comment with a minus sign with no number following' do
      expect(
        pull_request.send(:comment_score, fake_negative_comment) == 0
      ).to eq(true)
    end
  end # single comment score

  context '#comment_body_html_strikethrus_removed' do
    it 'handles multiple strikethrus non-greedily' do
      comment = double(:comment, body: 'Hello ~~World~~ Lorem ipsum ~~dolor sit amet~~ Goodbye')
      expect(
        pull_request.send(:comment_body_html_strikethrus_removed, comment)
      ).to eq("<p>Hello  Lorem ipsum  Goodbye</p>\n")
    end
  end

  context '#has_blocker?' do
    it 'returns true when [blocker]' do
      expect(pull_request.send(:has_blocker?, blocker_comment)).to eq(true)
    end
    it 'returns true when [BLOCKER]' do
      expect(pull_request.send(:has_blocker?, blocker_comment_caps)).to eq(true)
    end
    it 'returns false when no [blocker]' do
      expect(pull_request.send(:has_blocker?, neutral_comment)).to eq(false)
    end
  end

  context 'all comment score' do
    let(:user) { Hashie::Mash.new(user: { login: 'bogus' }) }
    let(:comments_no_blocker) do
      [
        double(:comment, body: blocker_comment_struckthru, user: user),
        double(:comment, body: positive_comment, user: user),
        double(:comment, body: positive_comment, user: user),
        double(:comment, body: negative_comment, user: user),
        double(:comment, body: negative_comment, user: user),
        double(:comment, body: neutral_comment, user: user),
        double(:comment, body: positive_comment, user: user),
        double(:comment, body: positive_comment_struckthru, user: user),
        double(:comment, body: negative_comment_struckthru, user: user),
        double(:comment, body: negative_comment_struckthru_and_now_positive, user: user)
      ]
    end

    let(:comments_with_blocker) do
      [
        double(:comment, body: positive_comment, user: user),
        double(:comment, body: positive_comment, user: user),
        double(:comment, body: blocker_comment, user: user),
        double(:comment, body: positive_comment, user: user),
        double(:comment, body: negative_comment, user: user),
        double(:comment, body: neutral_comment, user: user)
      ]
    end

    it 'totals all comments' do
      expect_any_instance_of(Octokit::Client).to receive(:issue_comments).and_return(comments_no_blocker)
      expect(pull_request.score).to eq(1)
    end

    it 'returns zero if blocker exists' do
      expect_any_instance_of(Octokit::Client).to receive(:issue_comments).and_return(comments_with_blocker)
      expect(pull_request.score).to eq(0)
    end

    it 'logs the total score' do
      expect_any_instance_of(Logger).to receive(:info)
      pull_request.score
    end
  end

  context 'merge_pull_request' do
    it 'does not merge if already merged' do
      pr = double(:pull_request, merged?: true)
      expect_any_instance_of(Octokit::Client).to receive(:pull_request).and_return(pr)
      expect_any_instance_of(Octokit::Client).to_not receive(:merge_pull_request)
      pull_request.merge
    end

    it 'does merge if not already merged' do
      pr = double(:pull_request, merged?: false)
      expect_any_instance_of(Octokit::Client).to receive(:pull_request).and_return(pr)
      expect_any_instance_of(Octokit::Client).to receive(:merge_pull_request)
      pull_request.merge
    end
  end

end
