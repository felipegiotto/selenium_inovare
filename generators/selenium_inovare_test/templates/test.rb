require File.dirname(__FILE__) + '/../test_helper'

class <%= class_name %>Test < SeleniumInovare::TestCase

  #fixtures :all

  #Replace this with your REAL tests!!
  def test_should_do_some_stuff
    browser.open '/login'
    browser.type input('login'), 'quentin'
    browser.type "//a[@name='password']", 'monkey'
    browser.click submit
    browser.wait_for_page_to_load
  end

end
