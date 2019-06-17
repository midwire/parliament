# Parliament

A Ruby app that listens to GitHub events and automatically merges pull requests when specified they are mergeable.

## Usage

When Pull requests have satisfied the following criteria, they are automatically merged:
* The requirements configured in the GitHub repository are met for the base branch (the branch being merged into). This includes any branch protection requirements, like Continuous Integration checks, required number of approvals, user-specific required approvals, etc.
* The pull request can be merged.

## Installation/Setup

### Parliament
TBD

### GitHub
Setup is easy, just setup the webhook for all events to a repo and it'll start handling merge requests (Parliament handles `+form` and `+json`, so use what you'd prefer).

Make sure you add `/webhook` to the end of the URL, as follows:

```
https://www.yourserver.com/webhook
```

## Configuration
Parliament can be configured by setting configuration options within the configuration block in `application.rb`, i.e.

```ruby
Parliament.configure do |config|

  # Personal Access Token
  config.personal_access_token = <GitHub Personal Access Token>

  # current status must be success
  #
  # default: true
  config.check_status = false

  # an array of required voters' github usernames
  #
  # default: empty array
  config.required_usernames = ['databyte', 'c0', 'pasha']

  # also accepts an array-returning Proc that is called on each check with the raw data from the webhook.
  config.required_usernames = Proc.new { |data| ... }

  # an array of required CI contexts
  #
  # default: empty array
  config.required_contexts = ['ci/circleci: validate', 'codeclimate']

  # also accepts an array-returning Proc that is called on each check with the raw data from the webhook.
  config.required_contexts = Proc.new { |data| ... }

end
```

## Alternatives
* [plus-pull](https://github.com/christofdamian/plus-pull)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Running the Tests

`bundle exec rake`

## License

Parliament is released under the MIT License. See the bundled LICENSE file for
details.
