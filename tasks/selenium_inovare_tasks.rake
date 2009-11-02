
begin
  require 'selenium/rake/tasks'
rescue LoadError
  raise("You should install selenium-client gem with 'sudo gem install selenium-client'")
end

Selenium::Rake::RemoteControlStartTask.new do |rc|
  require File.dirname(__FILE__) + '/../lib/selenium_inovare'

  begin
    selenium_server_port = SeleniumInovare::PARAMS['selenium_server_port'] || raise
  rescue
    raise "File test/selenium_inovare/config.yml has an invalid structure! If you can't fix it, delete it so it can be generated again."
  end

  rc.port = selenium_server_port
  rc.timeout_in_seconds = 3 * 60
  rc.background = true
  rc.wait_until_up_and_running = true
  rc.jar_file = "#{ RAILS_ROOT }/vendor/plugins/selenium_inovare/selenium-server-1.0.1/selenium-server.jar"
  rc.additional_args << "-singleWindow"
end

Selenium::Rake::RemoteControlStopTask.new do |rc|
  require File.dirname(__FILE__) + '/../lib/selenium_inovare'

  begin
    selenium_server_port = SeleniumInovare::PARAMS['selenium_server_port'] || raise
  rescue
    raise "File test/selenium_inovare/config.yml has an invalid structure! If you can't fix it, delete it so it can be generated again."
  end

  rc.host = 'localhost'
  rc.port = selenium_server_port
  rc.timeout_in_seconds = 3 * 60
end

namespace :test do

  desc 'Run the integration tests in test/selenium_inovare'
  task :selenium_inovare do
    RAILS_ENV = 'test'
    require File.join(File.dirname(__FILE__), '../init')
    Dir.glob(RAILS_ROOT + '/test/selenium_inovare/*.rb').each do |file|
      require file
    end
  end

end