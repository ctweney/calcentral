require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/splash_page'
require_relative 'pages/my_profile_contact_info_page'

describe 'My Profile Contact Info', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      # initialize tests
    end

    describe 'phone number' do

      # PHONES - DISPLAY
      describe 'display' do
        it 'shows an "Add" button' # TODO
        context 'when a user has no phones' do
          it 'shows no "Edit" buttons'
          it 'shows a meaningful message'
        end
        context 'when a user has phones' do
          it 'shows an "Edit" button for each'
          it 'shows the phone type for each'
          it 'shows the phone number for each'
          it 'indicates which is preferred'
          context 'with extensions' do
            it 'shows the phone extensions'
          end
          context 'without extensions' do
            it 'shows no phone extensions'
          end
        end
      end

      # PHONES - ADDING
      describe 'adding' do
        it 'allows a user to add a new preferred phone'
        it 'allows a user to add a new non-preferred phone'
        it 'prevents a user adding a phone of the same type as an existing one'
        it 'requires that a phone number be entered'
        it 'allows a maximum of BLAH phone number characters to be entered' # TODO
        it 'allows a phone extension to be entered'
        it 'does not require that a phone extension be entered'
        it 'allows a maximum of BLAH phone extension characters to be entered' # TODO
        it 'allows a user to cancel the new phone'
        it 'allows a user to save the new phone'
      end

      # PHONES - EDITING
      describe 'editing' do
        it 'allows a user to un-prefer a preferred phone'
        it 'allows a user to prefer an un-preferred phone'
        it 'allows a user to change the phone type'
        it 'prevents a user changing a phone to the same type as an existing one'
        it 'requires that a phone number be entered'
        it 'allows a maximum of BLAH phone number characters to be entered' # TODO
        it 'allows a phone extension to be entered'
        it 'does not require that a phone extension be entered'
        it 'allows a maximum of BLAH phone extension characters to be entered' # TODO
        it 'allows a user to cancel the phone edit'
        it 'allows a user to save the phone edit'
      end

      # PHONES - DELETING
      describe 'deleting' do
        it 'allows a user to delete an un-preferred phone'
        it 'prevents a user deleting a preferred phone'
        it 'checks if the user is sure'
        it 'proceeds if the user is sure'
        it 'cancels if the user is not sure'
      end

    end

    describe 'email address' do

      # EMAIL - DISPLAY
      describe 'display' do
        it 'shows an "Add" button' # TODO
        context 'when a user has no email addresses' do
          it 'shows no "Edit" buttons'
          it 'shows a meaningful message'
        end
        context 'when a user has email addresses' do
          it 'shows an "Edit" button for each'
          it 'shows the email type for each'
          it 'shows the email address for each'
          it 'indicates which is preferred'
        end
      end

      # EMAIL - ADDING
      describe 'adding' do
        it 'allows a user to add a new preferred email'
        it 'allows a user to add a new non-preferred email'
        it 'prevents a user adding an email of the same type as an existing one'
        it 'requires that an email address be entered'
        it 'allows a maximum of BLAH phone number characters to be entered' # TODO
        it 'allows a user to cancel the new email'
        it 'allows a user to save the new email'
      end

      # EMAIL - EDITING
      describe 'editing' do
        it 'allows a user to un-prefer a preferred email'
        it 'allows a user to prefer a non-preferred email'
        it 'prevents a user changing an email type to the same type as an existing one'
        it 'requires that an email address be entered'
        it 'allows a maximum of BLAH phone number characters to be entered' # TODO
        it 'allows a user to cancel the email edit'
        it 'allows a user to save the email edit'
      end

      # EMAIL - DELETING
      describe 'deleting' do
        it 'allows a user to delete an un-preferred email'
        it 'prevents a user deleting a preferred email'
        it 'prevents a user deleting all emails'
        it 'checks if the user is sure'
        it 'proceeds if the user is sure'
        it 'cancels if the user is not sure'
      end

    end

    describe 'address' do

      # ADDRESS - DISPLAY
      describe 'address display' do
        it 'shows an "Add" button' # TODO
        context 'when a user has no addresses' do
          it 'shows no "Edit" buttons'
          it 'shows a meaningful message'
        end
        context 'when a user has addresses' do
          it 'shows an "Edit" button for each'
          it 'indicates which is preferred'
          it 'shows the address type for each'
          it 'shows the Address 1 for each'
          it 'shows the Country for each'
          it 'shows a preferred indicator for one'
          context 'with Address 2' do
            it 'shows the Address 2'
          end
          context 'with Address 3' do
            it 'shows the Address 3'
          end
          context 'with City' do
            it 'shows the City'
          end
          context 'with State' do
            it 'shows the State'
          end
          context 'with Postal Code' do
            it 'shows the Postal Code'
          end
        end

        # ADDRESS - ADDING
        describe 'address adding' do
          it 'allows a user to add a new preferred address'
          it 'allows a user to add a new non-preferred address'
          it 'prevents a user adding an address of the same type as an existing one'
          it 'requires a user to enter an Address 1'
          it 'allows a maximum of BLAH Address 1 characters to be entered' # TODO
          it 'requires a user to select a Country' # TODO
          it 'allows a user to enter an Address 2' # TODO
          it 'does not require a user to enter an Address 2'
          it 'allows a user to enter an Address 3' # TODO
          it 'does not require a user to enter an Address 3'
          it 'allows a user to enter a City' # TODO
          it 'does not require a user to enter a City'
          it 'requires a user to enter a State if the Country is "United States"' # TODO
          it 'does not require a user to enter a State if the Country is not "United States"' # TODO
          it 'allows a user to enter a Postal Code' # TODO
          it 'does not require a user to enter a Postal Code'
          it 'allows a user to cancel the new address'
          it 'allows a user to save the new address'
        end

        # ADDRESS - EDITING
        describe 'address editing' do
          it 'allows a user to un-prefer a preferred address'
          it 'allows a user to prefer a non-preferred address'
          it 'prevents a user changing an address type to the same type as an existing one'
          it 'requires a user to enter an Address 1'
          it 'allows a maximum of BLAH Address 1 characters to be entered' # TODO
          it 'requires a user to select a Country' # TODO
          it 'allows a user to enter an Address 2' # TODO
          it 'does not require a user to enter an Address 2'
          it 'allows a user to enter an Address 3' # TODO
          it 'does not require a user to enter an Address 3'
          it 'allows a user to enter a City' # TODO
          it 'does not require a user to enter a City'
          it 'requires a user to enter a State if the Country is "United States"' # TODO
          it 'does not require a user to enter a State if the Country is not "United States"' # TODO
          it 'allows a user to enter a Postal Code' # TODO
          it 'does not require a user to enter a Postal Code'
          it 'allows a user to cancel the address edit'
          it 'allows a user to save the address edit'
        end

        # ADDRESS - DELETING
        describe 'address deleting' do # TODO
          it 'allows a user to delete an un-preferred address'
          it 'prevents a user deleting a preferred address'
          it 'prevents a user deleting all addresses'
          it 'checks if the user is sure'
          it 'proceeds if the user is sure'
          it 'cancels if the user is not sure'
        end

      end
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

  end
end
