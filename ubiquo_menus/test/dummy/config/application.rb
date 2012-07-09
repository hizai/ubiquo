require File.expand_path('../boot', __FILE__)

require "rails/all"

Bundler.require

require "ubiquo_core"
require "ubiquo_media"

module Dummy
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Default in Rails 3.2.3, so it should be supported
    config.active_record.whitelist_attributes = true
  end
end