module CalCentralPages

  class MyProfilePage

    include PageObject
    include CalCentralPages
    include ClassLogger

    link(:basic_info_link, :text => 'Basic Information')
    link(:contact_info_link, :text => 'Contact Information')
    link(:emergency_contact_link, :text => 'Emergency Contact')
    link(:demographic_info_link, :text => 'Demographic Information')
    link(:languages_link, :text => 'Languages')
    link(:work_experience_link, :text => 'Work Experience')
    link(:honors_and_awards_link, :text => 'Academic Honors and Awards')

    def click_contact_info
      WebDriverUtils.wait_for_element_and_click contact_info_link_element
    end

  end
end
