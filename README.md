# What is this?

This is a tool to analyse how long it takes to merge dependabot PRs.

# Dependencies

 - Ruby (tested with `3.1.3`)
 - gh cli (`brew install gh`)
 - bundler (`gem install bundler`)
 - Install with `bundle install` if you haven't already.

# Usage

Run `bundle exec ruby dependabot_report.rb`

# How it works

This uses the GitHub CLI to search for relevant js dependency updates, then uses ruby to analyse the results to report 
on how many are merged within 1 week (our KPI).
