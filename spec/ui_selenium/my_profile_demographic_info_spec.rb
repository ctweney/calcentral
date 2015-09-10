require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/splash_page'
require_relative 'pages/my_profile_page'

describe 'My Profile Demographic Info', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      # initialize tests
    end

    describe 'Basic Info' do

    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

  end
end
