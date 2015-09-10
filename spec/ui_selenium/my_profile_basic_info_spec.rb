require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/splash_page'
require_relative 'pages/my_profile_page'

describe 'My Profile Basic Info', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      # initialize tests
    end

    # PHOTO
    describe 'profile photo' do

      describe 'display' do

        context 'when a user has a photo' do
          it 'shows the user\'s photo'
          it 'shows no "Add" button' # TODO
          it 'shows an "Edit" button' # TODO
        end

        context 'when a user has no photo' do
          it 'shows a placeholder image'
          it 'shows an "Add" button' # TODO
          it 'shows no "Edit" button' # TODO
        end
      end

      describe 'adding' # TODO

      describe 'editing' # TODO

      describe 'deleting' # TODO

    end

    # OFFICIAL NAME
    describe 'official name' do

      describe 'display' do

        it 'shows an "Edit" button' # TODO

        context 'when a user has first name, middle name, last name, and suffix' do
          it 'shows the first name, middle name, last name, and suffix'
        end
      end

      describe 'editing' # TODO

    end

    # PREFERRED NAME
    describe 'preferred name' do

      describe 'display' do

        context 'when a user has first name, middle name, last name, and suffix' do
          it 'shows the first name, middle name, last name, and suffix'
        end
      end

      describe 'adding' # TODO

      describe 'editing' do

        it 'allows only the first name to be edited'
        it 'allows a user to save the edited name'
        it 'allows a user to cancel the edited name'

      end

      describe 'deleting' # TODO

    end

    # IDS
    describe 'SID' do

      context 'when a user has an SID' do
        it 'shows the SID and its label'
      end

      context 'when a user has no SID' do
        it 'shows no SID section'
      end
    end

    describe 'UID' do

      context 'when a user has an UID' do
        it 'shows the UID and its label'
      end

      context 'when a user has no UID' do # TODO
        it 'shows no UID section'
      end
    end

    describe 'EID' do

      context 'when a user has an EID' do
        it 'shows the EID and its label' # TODO
      end

      context 'when a user has no EID' do
        it 'shows no EID section'
      end
    end
  end

  after(:all) do
    WebDriverUtils.quit_browser(@driver)
  end

end
