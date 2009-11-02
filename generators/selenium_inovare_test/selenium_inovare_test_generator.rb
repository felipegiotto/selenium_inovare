#require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")
#require 'digest/sha1'
class SeleniumInovareTestGenerator < Rails::Generator::NamedBase
  attr_reader :class_name

  def initialize(runtime_args, runtime_options = {})
    super
    @class_name = file_name.camelize
  end

  def manifest
    recorded_session = record do |m|

      m.class_collisions class_path,                  "#{class_name}"

      m.directory File.join('test/selenium_inovare', class_path)
      m.directory File.join('test/selenium_inovare/selectors', class_path)
      m.template 'test.rb',
        File.join('test/selenium_inovare',
        class_path,
        "#{file_name}_test.rb")
    end

    recorded_session
  end

  protected

  def banner
    "Usage: #{$0} selenium_inovare_test TestCaseName"
  end
end
