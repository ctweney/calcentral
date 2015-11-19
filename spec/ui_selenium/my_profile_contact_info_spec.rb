describe 'My Profile Contact Info', :testui => true, :order => :defined do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    test_users = UserUtils.load_profile_test_data
    student = test_users.find { |user| user['type'] == 'newStudent' }
    contact_info = student['contactInfo']
    addresses = contact_info['addresses']

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      @driver.manage.window.maximize
      @splash_page = CalCentralPages::SplashPage.new @driver
      @cal_net_page = CalNetAuthPage.new @driver
      @my_dashboard = CalCentralPages::MyDashboardPage.new @driver
      @contact_info_card = CalCentralPages::MyProfileContactInfoCard.new @driver

      @splash_page.log_into_dashboard(@driver, @cal_net_page, student['username'], student['password'])
      @my_dashboard.click_profile_link @driver
      @contact_info_card.click_contact_info
      @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) do
        @contact_info_card.phone_label_element.visible?
        @contact_info_card.email_label_element.visible?
      end
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    describe 'phone number' do

      before(:all) do
        # Get rid of any existing phone data
        @contact_info_card.delete_all_phones
        @possible_phone_types = ['Local', 'Mobile', 'Home/Permanent']
      end

      describe 'adding' do

        it 'requires that a phone number be entered' do
          @contact_info_card.click_add_phone
          @contact_info_card.enter_phone(nil, '', '123', nil)
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to eql('true')
          @contact_info_card.click_cancel_phone
        end
        it 'allows a user to add a new phone' do
          phone = contact_info['phones'].find { |phone| phone['type'] == 'Home/Permanent' }
          @contact_info_card.add_new_phone(phone['type'], phone['phoneNumberInput'], phone['phoneExt'], false)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.phone_types.include? phone['type'] }
          index = @contact_info_card.phone_type_index(phone['type'])
          expect(@contact_info_card.phone_primary? index).to be true
          expect(@contact_info_card.phone_numbers[index]).to eql(phone['phoneNumberDisplay'])
          expect(@contact_info_card.phone_extensions[index]).to eql("ext. #{phone['phoneExt']}") unless phone['phoneExt'].nil?
        end
        it 'prevents a user adding a phone of the same type as an existing one' do
          @contact_info_card.click_add_phone
          expect(@contact_info_card.phone_type_options).not_to include('Home/Permanent')
        end
        it 'allows a user to save a new non-preferred phone' do
          phone = contact_info['phones'].find { |phone| phone['type'] == 'Mobile' }
          @contact_info_card.add_new_phone(phone['type'], phone['phoneNumberInput'], phone['phoneExt'], false)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.phone_types.include? phone['type'] }
          index = @contact_info_card.phone_type_index(phone['type'])
          expect(@contact_info_card.phone_primary? index).to be false
          expect(@contact_info_card.phone_numbers[index]).to eql(phone['phoneNumberDisplay'])
          expect(@contact_info_card.phone_extensions[index]).to eql("ext. #{phone['phoneExt']}") unless phone['phoneExt'].nil?
        end
        it 'allows a maximum number of characters to be entered in each field' do
          phone = contact_info['phones'].find { |phone| phone['type'] == 'Local' }
          @contact_info_card.add_new_phone(phone['type'], phone['phoneNumberInput'], phone['phoneExt'], false)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.phone_types.include? phone['type'] }
          index = @contact_info_card.phone_type_index(phone['type'])
          expect(@contact_info_card.phone_primary? index).to be false
          expect(@contact_info_card.phone_numbers[index]).to eql(phone['phoneNumberDisplay'].slice!(0..23))
          expect(@contact_info_card.phone_extensions[index]).to eql("ext. #{phone['phoneExt'].slice!(0..5)}") unless phone['phoneExt'].nil?
        end
      end

      describe 'editing' do

        before(:all) do
          @mobile_index = @contact_info_card.phone_type_index 'Mobile'
          @home_index = @contact_info_card.phone_type_index 'Home/Permanent'
          @local_index = @contact_info_card.phone_type_index 'Local'
        end

        it 'allows a user to choose a different preferred phone' do
          @contact_info_card.edit_phone(@mobile_index, nil, nil, true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.phone_primary? @mobile_index }
          expect(@contact_info_card.phone_primary? @home_index).to be false
        end
        it 'prevents a user de-preferring a phone if more than two phones exist' do
          @contact_info_card.edit_phone(@mobile_index, nil, nil, false)
          @contact_info_card.phone_validation_error_element.when_visible(WebDriverUtils.page_load_timeout)
          expect(@contact_info_card.phone_validation_error).to eql('One phone number must be checked as preferred')
        end
        it 'does not allow a user to change the phone type' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.add_phone_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.phone_type?).to be false
        end
        it 'allows a user to change the phone number and extension' do
          new_number = '098/765-4321'
          new_ext = '999'
          @contact_info_card.edit_phone(@mobile_index, new_number, new_ext, nil)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, "Phone number is unexpected: '#{@contact_info_card.phone_numbers[@mobile_index]}'") do
            @contact_info_card.phone_numbers[@mobile_index] == new_number
          end
          expect(@contact_info_card.phone_extensions[@mobile_index]).to eql("ext. #{new_ext}")
        end
        it 'requires that a phone number be entered' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.enter_phone(nil, '', nil, nil)
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to eql('true')
        end
        it 'does not require that a phone extension be entered' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.enter_phone(nil, '1234567890', nil, nil)
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to be_nil
        end
        it 'allows a maximum number of characters to be entered in each field' do
          phone = contact_info['phones'].find { |phone| phone['type'] == 'Local' }
          @contact_info_card.edit_phone(@local_index, phone['phoneNumberInput'], phone['phoneExt'], nil)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, "Phone number is unexpected: '#{@contact_info_card.phone_numbers[@local_index]}'") do
            @contact_info_card.phone_numbers[@local_index] == phone['phoneNumberDisplay']
          end
          expect(@contact_info_card.phone_primary? @local_index).to be false
          expect(@contact_info_card.phone_extensions[@local_index]).to eql("ext. #{phone['phoneExt'].slice!(0..5)}") unless phone['phoneExt'].nil?
        end
      end

      describe 'deleting' do

        before(:all) do
          @mobile_index = @contact_info_card.phone_type_index 'Mobile'
          @local_index = @contact_info_card.phone_type_index 'Local'
        end

        it 'prevents a user deleting a preferred phone if there are more than two phones' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.click_delete_phone
          @contact_info_card.phone_validation_error_element.when_visible WebDriverUtils.page_load_timeout
          expect(@contact_info_card.phone_validation_error).to eql('One Phone number must be checked as Preferred')
        end
        it 'allows a user to delete any un-preferred phone' do
          @contact_info_card.delete_phone @local_index
        end
      end
    end

    describe 'email address' do

      before(:all) do
        # Get rid of existing email if present
        @contact_info_card.delete_email
      end

      describe 'adding' do

        it 'allows a user to add an email of type "Other" only' do
          @contact_info_card.click_add_email
          expect(@contact_info_card.email_type_options).to eql(['Other'])
        end
        it 'requires that an email address be entered' do
          @contact_info_card.click_add_email
          expect(@contact_info_card.save_email_button_element.attribute('disabled')).to eql('true')
        end
        it 'allows a user to cancel the new email' do
          @contact_info_card.click_add_email
          @contact_info_card.click_cancel_email
          @contact_info_card.email_form_element.when_not_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address include the @ and . characters' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('foo', true)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address include the . character' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('foo@bar', true)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address include the @ character' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('foo.bar', true)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address contain at least one . following the @' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('foo.bar@foo', true)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address not contain @ as the first character' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('@foo.bar', true)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address not contain . as the last character' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('foo@bar.', true)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'allows a maximum of 70 email address characters to be entered' do
          @contact_info_card.click_add_email
          @contact_info_card.enter_email('foobar@foobar.foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo', true)
          @contact_info_card.click_save_email
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.email_types.include? 'Other' }
        end
        it 'prevents a user adding an email of the same type as an existing one' do
          expect(@contact_info_card.add_email_button?).to be false
        end

      end

      describe 'editing' do

        before(:all) do
          @index = @contact_info_card.email_type_index 'Other'
        end

        it 'allows a user to choose a different preferred email' do
          # This example requires that a campus email be present, which might not be true
          if @contact_info_card.email_types.include? 'Campus'
            @contact_info_card.edit_email(nil, false)
            @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { !@contact_info_card.email_primary?(@index) }
          else
            logger.warn 'Only one email exists, so skipping test for switching preferred emails'
          end
        end

        it 'allows a user to change the email address' do
          new_address = 'foo@bar.bar'
          @contact_info_card.edit_email(new_address, nil)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.email_addresses.include? new_address }
        end
        it 'requires that an email address be entered' do
          @contact_info_card.click_edit_email
          @contact_info_card.email_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.save_email_button_element.attribute('disabled')).to be_nil
        end
        it 'prevents a user changing an email type to the same type as an existing one' do
          @contact_info_card.click_edit_email
          @contact_info_card.email_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.email_type?).to be false
        end
        it 'requires that the email address include the @ and . characters' do
          @contact_info_card.click_edit_email
          @contact_info_card.enter_email('foo', nil)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address include the . character' do
          @contact_info_card.click_edit_email
          @contact_info_card.enter_email('foo@bar', nil)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address include the @ character' do
          @contact_info_card.click_edit_email
          @contact_info_card.enter_email('foo.bar', nil)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address contain at least one . following the @' do
          @contact_info_card.click_edit_email
          @contact_info_card.enter_email('foo.bar@foo', nil)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address not contain @ as the first character' do
          @contact_info_card.click_edit_email
          @contact_info_card.enter_email('@foo.bar', nil)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'requires that the email address not contain . as the last character' do
          @contact_info_card.click_edit_email
          @contact_info_card.enter_email('foo@bar.', nil)
          @contact_info_card.click_save_email
          @contact_info_card.email_validation_error_element.when_visible(WebDriverUtils.page_event_timeout)
        end
        it 'allows a maximum of 70 email address characters to be entered' do
          @contact_info_card.enter_email('foobar@foobar.foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo', true)
          @contact_info_card.click_save_email
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.email_types.include? 'Other' }
        end
      end

      describe 'deleting' do

        it 'allows a user to delete an email of type Other' do
          @contact_info_card.delete_email
        end

      end
    end

    describe 'address' do

      before(:all) do
        @contact_info_card.load_page
        @contact_info_card.address_label_element.when_visible WebDriverUtils.page_load_timeout
        unless @contact_info_card.address_types.include? 'Local'
          logger.info 'Cannot find Local address, adding it'
          @contact_info_card.add_address(addresses[0], addresses[0]['inputs'], addresses[0]['selects'])
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.address_types.include? 'Local' }
        end
        @addresses = @contact_info_card.address_formatted_elements.length
        @local_index = @contact_info_card.address_type_index 'Local'
        @home_index = @contact_info_card.address_type_index 'Home'
      end

      describe 'editing' do

        addresses.each do |address|

          it "shows a user custom address fields for #{address['country']}" do
            @contact_info_card.load_page
            @contact_info_card.click_edit_address @local_index
            @contact_info_card.load_country_form address
            @contact_info_card.verify_address_labels address
          end

          it "allows a user to enter an address for #{address['country']} with max character restrictions" do
            logger.info "Entering address in #{address['country']}"
            address_inputs = address['inputs']
            logger.info "There are #{address_inputs.length} inputs expected"
            address_selects = address['selects']
            logger.info "There are #{address_selects.length} selects expected" unless address_selects.nil?
            @contact_info_card.load_page
            @contact_info_card.edit_address(@local_index, address, address_inputs, address_selects)
            @contact_info_card.click_save_address
            @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.address_formatted_elements.length == @addresses }
            @contact_info_card.verify_address(@local_index, address_inputs, address_selects)
          end
          it "requires a user to complete certain fields for an address in #{address['country']}" do
            @contact_info_card.load_page
            @contact_info_card.click_edit_address @local_index
            @contact_info_card.clear_address_fields(address, address['inputs'], address['selects'])
            @contact_info_card.click_save_address
            @contact_info_card.verify_req_field_error address
          end
          it "allows a user to cancel the new address in #{address['country']}" do
            @contact_info_card.click_cancel_address if @contact_info_card.cancel_address_button_element.visible?
            current_address = @contact_info_card.formatted_address @local_index
            @contact_info_card.click_edit_address @local_index
            @contact_info_card.click_cancel_address
            expect(@contact_info_card.formatted_address @local_index).to eql(current_address)
          end
          it "allows a user to delete individual address fields from an address in #{address['country']}" do
            nonreq_address_inputs = address['inputs'].reject { |input| input['req'] }
            logger.info "There are #{nonreq_address_inputs.length} inputs that are not required"
            req_address_inputs = address['inputs'] - nonreq_address_inputs
            logger.info "There are #{req_address_inputs.length} inputs that are required"
            @contact_info_card.click_edit_address @local_index
            @contact_info_card.clear_address_fields(address, nonreq_address_inputs, address['selects'])
            @contact_info_card.click_save_address
            sleep 3
            @contact_info_card.verify_address(@local_index, req_address_inputs, [])
          end
          it 'prevents a user adding an address of the same type as an existing one' do
            expect(@contact_info_card.add_address_button?).to be false
          end

        end
      end

      describe 'deleting' do

        it 'prevents a user deleting an address of type Home/Permanent' do
          @contact_info_card.click_edit_address @home_index
          expect(@contact_info_card.delete_address_button?).to be false
        end
        it 'prevents a user deleting an address of type Local' do
          @contact_info_card.click_edit_address @local_index
          expect(@contact_info_card.delete_address_button?).to be false
        end

      end
    end
  end
end
