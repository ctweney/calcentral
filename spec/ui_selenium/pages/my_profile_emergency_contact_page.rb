require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_profile_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyProfileEmergencyContactPage < MyProfilePage

    include PageObject
    include ClassLogger

    elements(:emergency_contact, :div, :xpath => '//div[@data-ng-repeat="emergencyContact in emergencyContacts.content"]')
    button(:add_emergency_contact_button, :xpath => '') # TODO

    def contact_name(index)
      emergency_contact_elements[index].div_element(:xpath => '//strong[@data-ng-bind="emergencyContact.name.formattedName"]')
    end

    def contact_relationship(index)
      emergency_contact_elements[index] # TODO
    end

    def contact_phone(index)
      emergency_contact_elements[index].div_element(:xpath => '//div[@data-ng-bind="emergencyContact.phone.number"]') # TODO - add phones
    end

    def contact_email(index)
      emergency_contact_elements[index].div_element(:xpath => '//div[@data-ng-bind="emergencyContact.email.emailAddress"]')
    end

    def contact_edit_button(index)
      emergency_contact_elements[index].button_element(:xpath => '//button[text()="Edit"]')
    end

  end

end
