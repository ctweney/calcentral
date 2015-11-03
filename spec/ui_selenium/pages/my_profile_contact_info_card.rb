require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_profile_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyProfileContactInfoCard < MyProfilePage

    include PageObject
    include ClassLogger

    elements(:phone, :div, :xpath => '//div[@data-ng-repeat="phone in phones.content"]')
    button(:add_phone_button, :xpath => '//button[@data-ng-click="showAddPhone()"]')
    select_list(:phone_type, :id => 'cc-page-widget-profile-phone-type')
    text_area(:phone_number_input, :id => 'cc-page-widget-profile-phone-number')
    text_area(:phone_ext_input, :id => 'cc-page-widget-profile-phone-extension')
    checkbox(:phone_preferred_cbx, :id => 'cc-page-widget-profile-phone-preferred')
    button(:phone_save_button, :xpath => '//div[@data-ng-if="phone.isModifying"]//button[contains(.,"Save")]')
    button(:phone_cancel_button, :xpath => '//div[@data-ng-if="phone.isModifying"]//button[contains(.,"Cancel")]')

    elements(:email, :div, :xpath => '//div[@data-ng-repeat="email in emails.content"]')
    button(:add_email_button, :xpath => '//button[@data-ng-click="showAddEmail()"]')
    select_list(:email_type, :xpath => '//select[@data-ng-options="emailType.fieldvalue as emailType.xlatlongname for emailType in emailTypes"]')
    text_area(:email_address, :id => 'cc-page-widget-profile-email-address')
    checkbox(:email_preferred_cbx, :id => 'cc-page-widget-profile-email-preferred')
    button(:email_save_button, :xpath => '//div[@data-ng-if="email.isModifying"]//button[contains(.,"Save")]')
    button(:email_cancel_button, :xpath => '//div[@data-ng-if="email.isModifying"]//button[contains(.,"Cancel")]')

    elements(:address, :div, :xpath => '//div[@data-ng-repeat="address in addresses.content"]')
    button(:add_address_button, :xpath => '') # TODO

    # PHONE

    def phone_type(index)
      phone_elements[index].div_element(:xpath => '//strong')
    end

    def phone_primary?(index)
      true unless phone_elements[index].span_element(:xpath => '//span[@data-ng-if="phone.primary"]').nil?
    end

    def phone_number(index)
      phone_elements[index].div_element(:xpath => '//div[@data-ng-bind="phone.number"]')
    end

    def phone_edit_button(index)
      phone_elements[index].button_element(:xpath => '//button[text()="Edit"]')
    end

    def edit_phone(index, type, number, ext, pref)
      phone_edit_button(index).click
      phone_type_element.when_visible timeout=WebDriverUtils.page_event_timeout
      self.phone_type = type
      self.phone_number_input = number unless number.nil?
      self.phone_ext_input = ext unless ext.nil?
      check_phone_preferred_cbx if pref
    end

    def save_phone
      phone_save_button
    end

    def cancel_phone
      phone_cancel_button
    end

    # EMAIL ADDRESS

    def email_type(index)
      email_elements[index].div_element(:xpath => '//strong')
    end

    def email_primary?(index)
      true unless email_elements[index].span_element(:xpath => '//span[@data-ng-if="phone.primary"]').nil?
    end

    def email_address(index)
      email_elements[index].div_element(:xpath => '//div[@data-ng-bind="phone.number"]')
    end

    def email_edit_button(index)
      email_elements[index].button_element(:xpath => '//button[text()="Edit"]')
    end

    def edit_email(index, type, address, pref)
      email_edit_button(index).click
      email_type_element.when_visible timeout=WebDriverUtils.page_event_timeout
      self.email_type = type
      self.email_address = address unless address.nil?
      check_email_preferred_cbx if pref
    end

    # ADDRESS

    def address_type(index)
      address_elements[index].div_element(:xpath => '//strong')
    end

    def address_primary?(index)
      true unless address_elements[index].span_element(:xpath => '//span[@data-ng-if="address.primary"]').nil?
    end

    def address_1(index)
      address_elements[index].div_element(:xpath => '//div[@data-ng-bind="address.street1"]')
    end

    def address_edit_button(index)
      address_elements[index].button_element(:xpath => '//button[text()="Edit"]')
    end

  end
end
