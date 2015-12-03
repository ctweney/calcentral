require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_profile_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyProfileBasicInfoCard < MyProfilePage

    include PageObject
    include ClassLogger

    div(:name, :xpath => '//div[@data-ng-bind="name.content.formattedName"]')

    div(:preferred_name, :xpath => '//div[@data-ng-bind="items.content[0].givenName"]')
    button(:preferred_name_add_button, :xpath => '//button[text()="Add"]')
    button(:preferred_name_edit_button, :xpath => '//button[text()="Edit"]')
    text_area(:preferred_name_input, :id => 'cc-page-widget-basic-preferred-first-name')
    button(:preferred_name_save_button, :xpath => '//button[@type="submit"]')
    button(:preferred_name_cancel_button, :xpath => '//button[@data-ng-click="closeEditor()"]')

    div(:sid, :xpath => '//div[@data-ng-bind="api.user.profile.sid"]')
    div(:uid, :xpath => '//div[@data-ng-bind="api.user.profile.uid"]')

    def load_page
      navigate_to "#{WebDriverUtils.base_url}/profile/basic"
    end

    def click_add_pref_name_button
      logger.info 'Clicking Add button for preferred name'
      WebDriverUtils.wait_for_element_and_click preferred_name_add_button_element
    end

    def click_edit_pref_name_button
      logger.info 'Clicking Edit button for preferred name'
      WebDriverUtils.wait_for_element_and_click preferred_name_edit_button_element
    end

    def enter_preferred_name(first_name)
      logger.info "Entering preferred name '#{first_name}'"
      WebDriverUtils.wait_for_element_and_type(preferred_name_input_element, first_name)
    end

    def click_save_pref_name_button
      logger.info 'Clicking Save button for preferred name'
      WebDriverUtils.wait_for_element_and_click preferred_name_save_button_element
    end

    def click_cancel_pref_name_button
      logger.info 'Clicking Cancel button for preferred name'
      WebDriverUtils.wait_for_element_and_click preferred_name_cancel_button_element
    end

    def edit_pref_name(new_name)
      click_edit_pref_name_button
      enter_preferred_name new_name
      click_save_pref_name_button
    end

  end
end
