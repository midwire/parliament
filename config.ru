# frozen_string_literal: true

require 'parliament'
require 'logger'

# Configure the app by editing application.rb.
require './application'

run Parliament::Server.new
