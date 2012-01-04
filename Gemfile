source :rubygems

# Dependencies are generated using a strict version. Don't forget to edit the
# dependency versions when upgrading.

merb_gems_version = '1.1.3'
merb_related_gems = '~> 1.1.0'
dm_gems_version   = '1.1.0'

# merb core
gem 'merb-core'                , merb_gems_version
# gem 'merb-action-args'         , merb_gems_version
gem 'merb-assets'              , merb_gems_version
gem 'merb-helpers'             , merb_gems_version
gem 'merb-mailer'              , merb_gems_version
gem 'merb-slices'              , merb_gems_version
gem 'merb-param-protection'    , merb_gems_version
gem 'merb-exceptions'          , merb_gems_version
gem 'merb-gen'                 , merb_gems_version

# merb authentication framework
gem 'merb-auth-core'           , merb_related_gems
gem 'merb-auth-more'           , merb_related_gems
gem 'merb-auth-slice-password' , merb_related_gems

# merb haml plugin
gem 'merb-haml'                , merb_gems_version

# merb dm plugin
gem 'merb_datamapper'          , merb_gems_version

# dm core
gem 'dm-core'                  , dm_gems_version
gem 'dm-aggregates'            , dm_gems_version
gem 'dm-migrations'            , dm_gems_version
gem 'dm-timestamps'            , dm_gems_version
gem 'dm-types'                 , dm_gems_version
gem 'dm-validations'           , dm_gems_version
gem 'dm-serializer'            , dm_gems_version
gem 'dm-transactions'          , dm_gems_version
gem 'dm-mysql-adapter'         , dm_gems_version

# dm extras
gem 'dm-paperclip'
gem 'dm-pagination'
gem 'dm-pagination'
gem 'dm-observer'              , dm_gems_version
gem 'dm-is-tree'               , dm_gems_version

# i18n
gem 'i18n'                     , '0.6.0'
gem 'i18n-translators-tools'   , '0.2.4', :require => 'i18n-translate'

# extras
gem 'htmldoc'
gem 'uuid'
gem 'builder'
gem 'gettext'
gem 'tlsmail'

# pdf-generation
# PDF functionality should be ported to Prawn, pdf-writer is no longer maintained.
# We use this fork because it contains fixes for ruby 1.9
gem 'pdf-writer'                , :git => "git://github.com/tundal45/pdf-writer.git"

group :development do
  # maintainer slice
  gem 'dm-sqlite-adapter'        , dm_gems_version
  gem 'git'                      , '1.2.5'
  #merb depends on this older version of rspec
  gem 'rspec'					   ,'1.3', :require => 'spec'
end
