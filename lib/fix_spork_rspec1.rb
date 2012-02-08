# This is a quick monkeypatch to fix Spork for RSpec 1.1
# https://github.com/sporkrb/spork/pull/171

class Spork::TestFramework::RSpec < Spork::TestFramework
  def rspec1?
    defined?(::Spec) && !defined?(::RSpec)
  end
end
