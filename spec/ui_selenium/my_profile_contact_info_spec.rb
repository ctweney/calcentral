describe 'My Profile Contact Info', :testui => true, :order => :defined do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer == 'local'

    include ClassLogger

    # Load a test data file.  See sample in the ui_selenium fixtures dir.
    test_users = UserUtils.load_profile_test_data
    student = test_users.first
    contact_info = student['contactInfo']
    addresses = contact_info['addresses']

    before(:all) do
      @driver = WebDriverUtils.launch_browser
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
        @contact_info_card.address_label_element.visible?
      end
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    describe 'phone number' do

      before(:all) do
        # Get rid of any existing phone data
        @contact_info_card.delete_all_phones
        @possible_phone_types = %w(Local, Mobile, Home/Permanent)
        @phones = contact_info['phones']
      end

      describe 'adding' do

        before(:all) do
          @mobile_phone = @phones.find { |phone| phone['type'] == 'Mobile' && phone['test'] == 'adding' }
          @home_phone = @phones.find { |phone| phone['type'] == 'Home/Permanent' && phone['test'] == 'adding' }
          @local_phone = @phones.find { |phone| phone['type'] == 'Local' && phone['test'] == 'adding' }
        end

        it 'requires that a phone number be entered' do
          @contact_info_card.click_add_phone
          @contact_info_card.save_phone_button_element.when_visible WebDriverUtils.page_event_timeout
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to eql('true')
          @contact_info_card.click_cancel_phone
        end
        it 'allows a user to add a new phone' do
          @contact_info_card.add_new_phone @home_phone
          @contact_info_card.verify_phone(@home_phone, true)
        end
        it 'prevents a user adding a phone of the same type as an existing one' do
          @contact_info_card.click_add_phone
          expect(@contact_info_card.phone_type_options).not_to include('Home/Permanent')
        end
        it 'allows a user to save a new non-preferred phone' do
          @contact_info_card.add_new_phone @mobile_phone
          @contact_info_card.verify_phone @mobile_phone
        end
        it 'allows a maximum number of characters to be entered in each field' do
          @contact_info_card.add_new_phone @local_phone
          @contact_info_card.verify_phone @local_phone
        end
      end

      describe 'editing' do

        before(:all) do
          @mobile_phone = @phones.find { |phone| phone['type'] == 'Mobile' && phone['test'] == 'editing' }
          @home_phone = @phones.find { |phone| phone['type'] == 'Home/Permanent' && phone['test'] == 'editing' }
          @local_phone = @phones.find { |phone| phone['type'] == 'Local' && phone['test'] == 'editing' }

          @mobile_index = @contact_info_card.phone_type_index 'Mobile'
          @home_index = @contact_info_card.phone_type_index 'Home/Permanent'
          @local_index = @contact_info_card.phone_type_index 'Local'
        end

        it 'allows a user to change the phone number and extension' do
          @contact_info_card.edit_phone(@mobile_index, @mobile_phone)
          @contact_info_card.verify_phone @mobile_phone
        end
        it 'allows a user to choose a different preferred phone' do
          @contact_info_card.edit_phone(@mobile_index, @mobile_phone, true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.phone_primary? @mobile_index }
          expect(@contact_info_card.phone_primary? @home_index).to be false
        end
        it 'prevents a user de-preferring a phone if more than two phones exist' do
          @contact_info_card.edit_phone(@mobile_index, @mobile_phone)
          @contact_info_card.phone_validation_error_element.when_visible(WebDriverUtils.page_load_timeout)
          expect(@contact_info_card.phone_validation_error).to eql('One phone number must be checked as preferred')
        end
        it 'does not allow a user to change the phone type' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.add_phone_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.phone_type?).to be false
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
        it 'requires that a valid phone extension be entered' do
          @contact_info_card.edit_phone(@home_index, @home_phone)
          @contact_info_card.phone_validation_error_element.when_visible(WebDriverUtils.page_load_timeout)
          expect(@contact_info_card.phone_validation_error).to eql('Invalid Phone Extension number: ?')
        end
        it 'allows a maximum number of characters to be entered in each field' do
          @contact_info_card.edit_phone(@local_index, @local_phone)
          @contact_info_card.verify_phone @local_phone
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
          @contact_info_card.add_email('foo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address include the . character' do
          @contact_info_card.add_email('foo@bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address include the @ character' do
          @contact_info_card.add_email('foo.bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address contain at least one . following the @' do
          @contact_info_card.add_email('foo.bar@foo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address not contain @ as the first character' do
          @contact_info_card.add_email('@foo.bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address not contain . as the last character' do
          @contact_info_card.add_email('foo@bar.', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'allows a maximum of 70 email address characters to be entered' do
          @contact_info_card.add_email('foobar@foobar.foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, "Visible email types are '#{@contact_info_card.email_types}'") do
            @contact_info_card.email_types.include? 'Other'
          end
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
            @contact_info_card.edit_email nil
            @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { !@contact_info_card.email_primary?(@index) }
          else
            logger.warn 'Only one email exists, so skipping test for switching preferred emails'
          end
        end

        it 'allows a user to change the email address' do
          new_address = 'foo@bar.bar'
          @contact_info_card.edit_email(new_address, true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, 'New email was not saved') do
            @contact_info_card.email_addresses.include? new_address
          end
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
          @contact_info_card.edit_email('foo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address include the . character' do
          @contact_info_card.edit_email('foo@bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address include the @ character' do
          @contact_info_card.edit_email('foo.bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address contain at least one . following the @' do
          @contact_info_card.edit_email('foo.bar@foo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address not contain @ as the first character' do
          @contact_info_card.edit_email('@foo.bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address not contain . as the last character' do
          @contact_info_card.edit_email('foo@bar.', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'allows a maximum of 70 email address characters to be entered' do
          @contact_info_card.edit_email('foobar@foobar.foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.email_types.include? 'Other' }
        end
      end

      describe 'deleting' do

        it 'allows a user to delete an email of type Other' do
          @contact_info_card.delete_email
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { !@contact_info_card.email_types.include? 'Other' }
        end

      end
    end

    describe 'address' do

      # Make sure the user has both Local and Home addresses before proceeding
      before(:all) do
        @contact_info_card.load_page
        @contact_info_card.address_label_element.when_visible WebDriverUtils.page_load_timeout
        unless @contact_info_card.address_types.include? 'Local'
          logger.warn 'Cannot find Local address, adding it'
          @contact_info_card.add_address(addresses[0], addresses[0]['inputs'], addresses[0]['selects'])
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, 'Local address was not added') do
            @contact_info_card.address_types.include? 'Local'
          end
        end
        @local_index = @contact_info_card.address_type_index 'Local'
        unless @contact_info_card.address_types.include? 'Home'
          logger.warn 'Cannot find Home address, adding it'
          @contact_info_card.add_address(addresses[0], addresses[0]['inputs'], addresses[0]['selects'])
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, 'Home address was not added') do
            @contact_info_card.address_types.include? 'Home'
          end
        end
        @home_index = @contact_info_card.address_type_index 'Home'
        @addresses = @contact_info_card.address_formatted_elements.length
      end

      describe 'editing' do

        # Iterate through each address in the test data file to exercise the internationalized address forms
        addresses.each do |address|

          it "allows a user to enter an address for #{address['country']} with max character restrictions" do
            address_inputs = address['inputs']
            address_selects = address['selects']
            @contact_info_card.load_page
            @contact_info_card.edit_address(@local_index, address, address_inputs, address_selects)
            @contact_info_card.verify_address(@local_index, address_inputs, address_selects)
            sleep 30
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
            req_address_inputs = address['inputs'] - nonreq_address_inputs
            @contact_info_card.click_edit_address @local_index
            @contact_info_card.clear_address_fields(address, nonreq_address_inputs, address['selects'])
            @contact_info_card.click_save_address
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
