describe 'My Profile Basic Info', :testui => true, :order => :defined do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    before(:all) do
      @test_users = UserUtils.load_profile_test_data
      logger.info "There are #{@test_users.length.to_s} test users"
      @driver = WebDriverUtils.launch_browser
      @splash_page = CalCentralPages::SplashPage.new @driver
      @cal_net_page = CalNetAuthPage.new @driver
      @my_dashboard = CalCentralPages::MyDashboardPage.new @driver
      @basic_info_card = CalCentralPages::MyProfileBasicInfoCard.new @driver
    end

    context 'for a new student,' do

      before(:all) do
        @student = @test_users.find { |user| user['type'] == 'newStudent' }
        @student_info = @student['basicInfo']
        @splash_page.log_into_dashboard(@driver, @cal_net_page, @student['username'], @student['password'])
        @my_dashboard.click_profile_link @driver
      end

      describe 'viewing official name' do

        it 'shows the first name, middle name, last name, and suffix' do
          @basic_info_card.name_element.when_visible WebDriverUtils.page_load_timeout
          expect(@basic_info_card.name).to eql("#{@student_info['officialName']['firstName']} #{@student_info['officialName']['lastName']}")
        end

      end

      describe 'viewing and editing preferred name' do

        before(:each) do
          @basic_info_card.preferred_name_element.when_visible WebDriverUtils.page_load_timeout
          # if preferred name is already set to one of the test names, then use the other one for this test
          (@basic_info_card.preferred_name == @student_info['preferredName']['option1']) ?
              @preferred_name = @student_info['preferredName']['option2'] :
              @preferred_name = @student_info['preferredName']['option1']
        end

        it 'allows the student to save an edited name' do
          @basic_info_card.edit_pref_name @preferred_name
          @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == @preferred_name }
        end

        it 'allows the student to cancel an edited name' do
          original_name = @basic_info_card.preferred_name
          @basic_info_card.click_edit_pref_name_button
          @basic_info_card.enter_preferred_name @preferred_name
          @basic_info_card.click_cancel_pref_name_button
          @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == original_name }
        end

        it 'allows a maximum of 30 characters for an edited name' do
          max_char_name = @student_info['preferredName']['maxChar']
          @basic_info_card.edit_pref_name max_char_name
          @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == max_char_name[0..29] }
        end

        it 'permits the use of special characters for an edited name' do
          special_char_name = @student_info['preferredName']['specChar']
          @basic_info_card.edit_pref_name special_char_name
          # TODO : @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == special_char_name }
        end
      end

      describe 'viewing SID' do

        it 'shows the SID and its label' do
          expect(@basic_info_card.sid).to eql(@student_info['sid'])
        end

      end

      describe 'viewing UID' do

        it 'shows the UID and its label' do
          expect(@basic_info_card.uid).to eql(@student_info['uid'])
        end

      end
    end

    context 'for an existing student' do

      before(:all) do
        @basic_info_card.log_out @splash_page
        @existing_student = @test_users.find { |user| user['type'] == 'existingStudent' }
        @splash_page.log_into_dashboard(@driver, @cal_net_page, @existing_student['username'], @existing_student['password'])
      end

      # TODO : it 'does what?'
      # TODO : it 'and then it does what?'

    end

    context 'for a non-student' do

      before(:all) do
        @basic_info_card.log_out @splash_page
        @non_student = @test_users.find { |user| user['type'] == 'nonStudent' }
        @splash_page.log_into_dashboard(@driver, @cal_net_page, @non_student['username'], @non_student['password'])
      end

      it 'offers no Profile link' do
        WebDriverUtils.wait_for_page_and_click @my_dashboard.gear_link_element
        @my_dashboard.settings_link_element.when_visible WebDriverUtils.page_event_timeout
        expect(@my_dashboard.profile_link?).to be false
      end

      it 'offers no Basic Info UI' do
        @basic_info_card.load_page
        #   TODO: what is expected UI?
      end

    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

  end
end
