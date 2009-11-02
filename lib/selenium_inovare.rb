#require "test/unit"
require 'rubygems'
require 'activesupport'
require 'active_support/test_case'
require "selenium/client"
require "selenium/client/protocol"

module Selenium::Client::Protocol

  #  def remote_control_command_with_symbols(*args)
  #    puts "Oi"
  #    remote_control_command_without_symbols(*args)
  #    puts "Oi2"
  #  end
  #
  #  alias_method_chain :remote_control_command, :symbols

  def click_and_wait(*locator)
    click(*locator)
    wait_for_page_to_load
  end

  def remote_control_command(verb, args=[])
    args.collect! do |arg|
      if arg.is_a? Symbol
        SeleniumInovare::SELECTORS[arg.to_s] || raise("Selector '#{arg}' not found in /test/selenium_inovare/selectors/*.yml")
      else
        arg
      end
    end
    timeout(@default_timeout_in_seconds) do
      status, response = http_post(http_request_for(verb, args))
      raise Selenium::CommandError, response unless status == "OK"
      response
    end
  end

end

module SeleniumInovare

  DEFAULT_SELENIUM_PARAMS = {'selenium_server_port' => 4444, 'application_server_url' => 'http://localhost:3000', 'application_server_environment' => 'development'}
  SELENIUM_CONFIG_FILE = RAILS_ROOT + '/test/selenium_inovare/config.yml'

  unless File.exists?(SELENIUM_CONFIG_FILE)
    FileUtils.mkpath(File.dirname(SELENIUM_CONFIG_FILE))
    File.open SELENIUM_CONFIG_FILE, 'w' do |f|
      f.print DEFAULT_SELENIUM_PARAMS.to_yaml
    end
  end

  PARAMS = YAML::load_file(SELENIUM_CONFIG_FILE)

  SELECTORS = {}
  Dir.glob(RAILS_ROOT + '/test/selenium_inovare/selectors/*.yml').each do |file|
    SELECTORS.merge! YAML::load_file(file)
  end

  class TestCase < ActiveSupport::TestCase

    @@fixtures = nil
    def self.fixtures(*fixtures)
      @@fixtures = fixtures
    end

    def link(link_description, link_href = nil)
      tag = "//a[text()='#{link_description}']"
      if link_href
        tag << "[@href='#{link_href}']"
      end
      tag
    end

    def input(name)
      "//input[@name='#{name}']"
    end

    def submit(value = '')
      tag = "//input[@type='submit']"
      unless value.blank?
        tag << "[@value='#{value}']"
      end
      tag
    end

    def run(*args, &block)
      return if method_name =~ /^default_test$/

      begin
        selenium_server_port = SeleniumInovare::PARAMS['selenium_server_port'] || raise
        application_server_url = SeleniumInovare::PARAMS['application_server_url'] || raise
        fixtures_environment = SeleniumInovare::PARAMS['application_server_environment'] || raise
      rescue
        raise "File test/selenium_inovare/config.yml has an invalid structure! If you can't fix it, delete it so it can be generated again."
      end

      begin
        if @@fixtures
          puts "Loading fixtures..."
          if @@fixtures == [:all]
            puts `rake db:fixtures:load RAILS_ENV=#{fixtures_environment}`
          else
            puts `rake db:fixtures:load RAILS_ENV=#{fixtures_environment} FIXTURES=#{ @@fixtures.join ',' }`
          end
        end
        
        @browser = Selenium::Client::Driver.new \
          :host => 'localhost',
          :port => selenium_server_port,
          :browser => "*firefox",
          :url => application_server_url,
          :timeout_in_second => 60

        browser.start_new_browser_session
      rescue Errno::ECONNREFUSED
        raise "It seems that Selenium Remote Control is not running! Type 'rake selenium:rc:start' before running integration tests."
      end

      super
      browser.close_current_browser_session
    end

    attr_reader :browser

  end

end
