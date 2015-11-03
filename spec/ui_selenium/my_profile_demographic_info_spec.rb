describe 'My Profile Demographic Info', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      # initialize tests
    end

    describe 'Basic Info' do

    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

  end
end
