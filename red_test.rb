require 'selenium-webdriver'
require 'test/unit'
require 'rspec'


class RedTest < Test::Unit::TestCase
  include RSpec::Matchers


  # Starting browser before each test
  def setup
    @browser = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
    @browser.get 'http://demo.redmine.org'
  end

  def test_registration
    registration
    # expected = 'Your account has been activated. You can now log in.'
    expect(@browser.find_element(:id, 'flash_notice').text).to include('Ваша учётная запись активирована. Вы можете войти.')

  end

  # logout-login

  def test_login
    login = rand(999).to_s + 'user'
    @browser.find_element(:class, 'register').click
    @browser.find_element(:id, 'user_login').send_keys login
    @browser.find_element(:id, 'user_password').send_keys 'password'
    @browser.find_element(:id, 'user_password_confirmation').send_keys 'password'
    @browser.find_element(:id, 'user_firstname').send_keys 'firstname'
    @browser.find_element(:id, 'user_lastname').send_keys 'lastname'
    @browser.find_element(:id, 'user_mail').send_keys login + '@bla.bla'
    @browser.find_element(:name, 'commit').click
    @browser.find_element(:class, 'logout').click
    @browser.find_element(:class, 'login').click
    @browser.find_element(:id, 'username').send_keys login
    @browser.find_element(:id, 'password').send_keys 'password'
    @browser.find_element(:name, 'login').click
    expected= login
    assert_equal(expected, @browser.find_element(:class, 'active').text)
  end

  #change password
  def test_password
  registration
  @browser.find_element(:class,'my-account').click
  @browser.find_element(:class, 'icon-passwd').click
  @browser.find_element(:id, 'password').send_keys 'password'
  @browser.find_element(:id, 'new_password').send_keys 'password1'
  @browser.find_element(:id, 'new_password_confirmation').send_keys 'password1'
  @browser.find_element(:name, 'commit').click
  #expected ='Password was successfully updated.'
  expected = 'Пароль успешно обновлён.'
  assert_equal(expected, @browser.find_element(:id, 'flash_notice').text)
  end

  #Create Project + Create Project version
  def test_project
  project
  @browser.find_element(:id, 'tab-versions').click
  sleep (2)
  @browser.find_element(:xpath, "//*[@id='tab-content-versions']/p[2]/a").click
  version = rand(999).to_s + 'version'
  @browser.find_element(:id, 'version_name').send_keys version
  @browser.find_element(:name, 'commit').click
  #expected = 'Successful creation.'
  expected = 'Создание успешно.'
  assert_equal(expected, @browser.find_element(:id, 'flash_notice').text)
  end

  #Add another (your) user to the Project + Edit their (users’) roles
  def MyUser
    @browser.find_element(:class, 'register').click
    @wait.until {@browser.find_element(:id => 'user_login').displayed?}
    @browser.find_element(:id, 'user_login').send_keys 'user8'
    @browser.find_element(:id, 'user_password').send_keys 'password'
    @browser.find_element(:id, 'user_password_confirmation').send_keys 'password'
    @browser.find_element(:id, 'user_firstname').send_keys 'firstname'
    @browser.find_element(:id, 'user_lastname').send_keys 'lastname'
    @browser.find_element(:id, 'user_mail').send_keys 'user8@bla.bla'
    @browser.find_element(:name, 'commit').click
  end
  def test_roles
    project
    @wait.until {@browser.find_element(:id => 'tab-members').displayed?}
    @browser.find_element(:id, 'tab-members').click
    @browser.find_element(:xpath, "//*[@id='tab-content-members']/p/a").click
    @wait.until {@browser.find_element(:id => 'principal_search').displayed?}
    @browser.find_element(:id, 'principal_search').send_keys 'user8'
    sleep (2)
    @browser.find_element(:xpath, "//*[@id='principals']/label").click
    @browser.find_element(:xpath, "//*[@id='new_membership']/fieldset[2]/div/label[1]/input").click
    @browser.find_element(:id, 'member-add-submit').click
    sleep (2)
    @browser.find_element(:xpath, "(.//*[@class='icon icon-edit'])[1]").click
    @browser.find_element(:xpath, "(.//input[@value='4'])").click
    @browser.find_element(:xpath, "(.//*[@class='small'])[2]").click
    sleep (2)
    form =@wait.until {element = @browser.find_element(:xpath => "//td[contains (., 'Developer')]").displayed?}
    puts 'Test Passed: user-s role was edit'
  end

  #Create all 3 types of issues + Ensure they are visible on ‘Issues’ tab

  def test_issues
    project
    @browser.find_element(:class, 'new-issue').click
    @wait.until {@browser.find_element(:id => 'issue_subject').displayed?}
    @browser.find_element(:id, 'issue_subject').send_keys 'bug'
    @browser.find_element(:name, 'continue').click
    sleep (2)
    option = Selenium::WebDriver::Support::Select.new(@browser.find_element(:css => "#issue_tracker_id"))
    option.select_by(:text, "Feature")
    @wait.until {@browser.find_element(:id => 'issue_subject').displayed?}
    @browser.find_element(:id, 'issue_subject').send_keys 'feature'
    @browser.find_element(:name, 'continue').click
    sleep (2)
    option = Selenium::WebDriver::Support::Select.new (@browser.find_element(:css => "#issue_tracker_id"))
    option.select_by(:text, "Support")
    @wait.until {@browser.find_element(:id => 'issue_subject').displayed?}
    sleep (2)
    @browser.find_element(:id, 'issue_subject').send_keys 'support'
    @browser.find_element(:name, 'continue').click
    @browser.find_element(:class, 'issues').click
    sleep (2)
    form =@wait.until {element = @browser.find_element(:xpath => "//td[contains (., 'Bug')]").displayed?}
    puts 'Test Passed: Issue Bug found'
    sleep (2)
    form =@wait.until {element = @browser.find_element(:xpath => "//td[contains (., 'Feature')]").displayed?}
    puts 'Test Passed: Issue Feature found'
    form =@wait.until {element = @browser.find_element(:xpath => "//td[contains (., 'Support')]").displayed?}
    puts 'Test Passed: Issue Support found'
  end



  #helpers
    def registration

      login = rand(999).to_s + 'user'
      @browser.find_element(:class, 'register').click
      @wait.until {@browser.find_element(:id => 'user_login').displayed?}
      @browser.find_element(:id, 'user_login').send_keys login
      @browser.find_element(:id, 'user_password').send_keys 'password'
      @browser.find_element(:id, 'user_password_confirmation').send_keys 'password'
      @browser.find_element(:id, 'user_firstname').send_keys 'firstname'
      @browser.find_element(:id, 'user_lastname').send_keys 'lastname'
      @browser.find_element(:id, 'user_mail').send_keys login + '@bla.bla'
      @browser.find_element(:name, 'commit').click
    end

  def project
    registration
    @browser.find_element(:class, 'projects').click
    sleep (3)
    @browser.find_element(:class, 'icon-add') .click
    sleep (2)
    project = rand(999).to_s + 'project'
    @browser.find_element(:id, 'project_name').send_keys project
    @browser.find_element(:id, 'project_identifier').send_keys project
    @browser.find_element(:name, 'commit').click
  end

  # Closing browser after each test
  def teardown
    @browser.quit
  end

end