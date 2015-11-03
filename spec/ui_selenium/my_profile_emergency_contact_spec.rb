describe 'My Profile Emergency Contact', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      # initialize tests
    end

    describe 'display' do

      it 'shows an "Add" button'

      context 'when a user has no contacts' do

        it 'shows no "Edit" buttons'
        it 'shows a meaningful message'

      end

      context 'when a user has a contact' do

        it 'shows an "Edit" button for each'
        it 'shows the Contact Name for each'
        it 'shows the Relationship for each'
        it 'indicates which is preferred'

        context 'who has an Address 1' do
          it 'shows the Address 1'
        end

        context 'who has an Address 2' do
          it 'shows the Address 2'
        end

        context 'who has an Address 3' do
          it 'shows the Address 3'
        end

        context 'who has a City' do
          it 'shows the City'
        end

        context 'who has a State' do
          it 'shows the State'
        end

        context 'who has a Postal Code' do
          it 'shows the Postal Code'
        end

        context 'who has a phone' do

          it 'shows the phone'

          context 'with an extension' do
            it 'shows the extension'
          end
        end

        context 'who has an email address' do
          it 'shows the email address'
        end
      end
    end

    describe 'adding' do

      # TODO: add input validation tests

      # NAME
      it 'allows a user to enter a contact name'
      it 'requires a user to enter a contact name'
      it 'allows a user to select a contact relationship'
      it 'requires a user to select a contact relationship'

      # ADDRESS
      it 'allows a user to enter an Address 1'
      it 'does not require a user to enter an Address 1' # TODO
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
      it 'requires a user to select a Country' # TODO

      # PHONES
      it 'allows a user to add a new preferred phone'
      it 'allows a user to add a new non-preferred phone'
      it 'requires that a phone number be entered' # TODO
      it 'allows a phone extension to be entered'
      it 'does not require that a phone extension be entered'
      it 'allows a maximum of BLAH phone extension characters to be entered' # TODO

      # EMAIL
      it 'allows a user to add an email address'
      it 'requires that an email address be entered' # TODO

      it 'allows a user to cancel the new contact'
      it 'allows a user to save the new contact'

    end

    describe 'editing' do

      # TODO: add input validation tests

      # NAME
      it 'allows a user to edit a contact name'
      it 'prevents a user from deleting a contact name'
      it 'allows a user to change a contact relationship'
      it 'prevents a user from deleting a contact relationship'

      # ADDRESS
      it 'allows a user to edit an Address 1'
      it 'allows a user to delete an Address 1' # TODO
      it 'allows a user to edit an Address 2' # TODO
      it 'allows a user to delete an Address 2'
      it 'allows a user to edit an Address 3' # TODO
      it 'allows a user to delete an Address 3'
      it 'allows a user to edit a City' # TODO
      it 'allows a user to delete a City'
      it 'allows a user to change a State if the Country is "United States"' # TODO
      it 'prevents a user from deleting a State if the Country is "United States"' # TODO
      it 'allows a user to delete a State if the Country is not "United States"' # TODO
      it 'allows a user to edit a Postal Code' # TODO
      it 'allows a user to delete a Postal Code'
      it 'allows a user to change a Country'
      it 'prevents a user from deleting a Country' # TODO

      # PHONES
      it 'allows a user to add a new preferred phone'
      it 'allows a user to add a new non-preferred phone'
      it 'requires that a phone number be entered' # TODO
      it 'allows a phone extension to be entered'
      it 'does not require that a phone extension be entered'
      it 'allows a maximum of BLAH phone extension characters to be entered' # TODO

      # EMAIL
      it 'allows a user to add an email address'
      it 'requires that an email address be entered' # TODO

      it 'allows a user to cancel the edited contact'
      it 'allows a user to save the edited contact'

    end

    describe 'deleting' do

      it 'allows a user to delete a contact'
      it 'allows a user to delete all contacts'
      it 'checks if the user is sure'
      it 'proceeds if the user is sure'
      it 'cancels if the user is not sure'

    end
  end

  after(:all) do
    WebDriverUtils.quit_browser(@driver)
  end

end
