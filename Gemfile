source :rubygems

# Dependencies are generated using a strict version. Don't forget to edit the
# dependency versions when upgrading.

merb_gems_version = '~> 1.1'
merb_related_gems = '~> 1.1'
dm_gems_version   = '~> 1.1'

# Merb
gem 'merb-core',                merb_gems_version
# gem 'merb-action-args',         merb_gems_version
gem 'merb-assets',              merb_gems_version
gem 'merb-helpers',             merb_gems_version
gem 'merb-mailer',              merb_gems_version
gem 'merb-slices',              merb_gems_version
gem 'merb-param-protection',    merb_gems_version
gem 'merb-exceptions',          merb_gems_version
gem 'merb-gen',                 merb_gems_version

# Merb authentication
gem 'merb-auth-core',           merb_related_gems
gem 'merb-auth-more',           merb_related_gems
gem 'merb-auth-slice-password', merb_related_gems

# Other Merb plugins
gem 'merb-haml',                merb_gems_version
gem 'merb_datamapper',          merb_gems_version

# DataMapper (or ORM)
gem 'dm-core',                  dm_gems_version
gem 'dm-aggregates',            dm_gems_version
gem 'dm-migrations',            dm_gems_version
gem 'dm-timestamps',            dm_gems_version
gem 'dm-types',                 dm_gems_version
gem 'dm-validations',           dm_gems_version
gem 'dm-serializer',            dm_gems_version
gem 'dm-transactions',          dm_gems_version
gem 'dm-mysql-adapter',         dm_gems_version

# DataMapper plugins
gem 'dm-paperclip'
gem 'dm-pagination'
gem 'dm-observer',              dm_gems_version
gem 'dm-is-tree',               dm_gems_version

# Other gems
gem 'i18n',                     '~> 0.6'
gem 'i18n-translators-tools',   '~> 0.2', :require => 'i18n-translate'
gem 'htmldoc'
gem 'uuid'
gem 'builder'
gem 'gettext'
gem 'tlsmail'
gem 'cronedit'
gem 'log4r'
gem 'rake',                     '~> 0.9'

# PDF functionality should be ported to Prawn, pdf-writer is no longer maintained.
# We use this fork because it contains fixes for ruby 1.9
gem 'pdf-writer',               :git => "git://github.com/tundal45/pdf-writer.git"

# Mostfit Maintainer slice
gem 'dm-sqlite-adapter',        dm_gems_version
gem 'git',                      '~> 1.2'

group :development do
  gem 'mongrel',                '1.2.0.pre2'  # needed for ruby-1.9 (jan'12)

  # This currently gives problems:
  # gem 'ruby-debug19'
  # So we install it system-wide with extra options as shown in INSTALL.md

  gem 'rspec',                  '~> 2.8'
  gem 'factory_girl',           '~> 2.3'
end

