require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyProfilePage

    include PageObject
    include CalCentralPages
    include ClassLogger

    link(:basic_info_link, :text => 'Basic Information')
    link(:contact_info_link, :text => 'Contact Information')
    link(:emergency_contact_link, :text => 'Emergency Contact')
    link(:academic_standing_link, :text => 'Academic Standing')
    link(:demographic_info_link, :text => 'Demographic Information')
    link(:record_access_link, :text => 'Record Access')
    link(:ferpa_restrictions_link, :text => 'FERPA Restrictions')
    link(:title_iv_release_link, :text => 'Title IV Release')
    link(:languages_link, :text => 'Languages')
    link(:work_experience_link, :text => 'Work Experience')
    link(:honors_and_awards_link, :text => 'Academic Honors and Awards')
    link(:fin_aid_awards_link, :text => 'Financial Aid Awards')
    link(:bconnected_link, :text => 'bConnected')

    def load_page
      navigate_to "#{WebDriverUtils.base_url}/profile"
    end

  end
end
