require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/splash_page'
require_relative 'pages/my_profile_page'

describe 'My Profile Academic Standing', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      # initialize tests
    end

    context 'when a user has a GPA' do
      it 'shows the GPA and its label'
    end
    context 'when a user has no GPA' do
      it 'shows no GPA section'
    end
    context 'when a user has a college but no major' do
      it 'shows the college and "Undeclared"'
    end
    context 'when a user has a college and a major' do
      it 'shows the college and the major'
    end
    context 'when a user has one college and two majors' do
      it 'shows the college once and each major'
    end
    context 'when a user has two colleges and two majors' do
      it 'shows each college and each major'
    end
    context 'when a user has no college and no major' do
      it 'shows no college and major section'
    end
    context 'when a user has standing' do
      it 'shows the standing and its label'
    end
    context 'when a user has no standing' do
      it 'shows no standing section'
    end
    context 'when a user has units' do
      it 'shows the units and its label'
    end
    context 'when a user has no units' do
      it 'shows no units section'
    end
    context 'when a user has a level' do
      it 'shows the level and its label'
    end
    context 'when a user has no level' do
      it 'shows no level section'
    end
    context 'when a user has an AP level (undergrad)' do
      it 'shows the AP level and its label'
    end
    context 'when a user has no AP level (non-undergrad)' do
      it 'shows no AP level section'
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

  end
end
