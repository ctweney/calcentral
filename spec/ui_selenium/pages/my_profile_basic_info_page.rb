require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_profile_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyProfileBasicInfoPage < MyProfilePage

    include PageObject
    include ClassLogger

    div(:name, :xpath => '//div[@data-ng-bind="name.content.formattedName"]')
    div(:preferred_name, :xpath => '//div[@data-ng-bind="preferredName.content.formattedName"]')
    div(:sid, :xpath => '//div[@data-ng-bind="api.user.profile.sid"]')
    div(:uid, :xpath => '//div[@data-ng-bind="api.user.profile.uid"]')

  end
end
