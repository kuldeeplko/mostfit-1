# This constant sets our release version to the string in the VERSION file.
# Make sure to update it before tagging a release.
# The versioning scheme follows the semver.org standard:
#   * when the existing database schema is modified -> public API changed

module Mostfit
  VERSION = File.open(Merb.root / 'VERSION').read.strip.freeze
end
