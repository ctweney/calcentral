describe User::Api do
  before(:each) do
    Settings.features.cs_profile = true
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @default_name = "Joe Default"
    HubEdos::UserAttributes.stub(:new).and_return(double(get: {
      :person_name => @default_name,
      :student_id => '1234567890',
      :campus_solutions_id => 'CC12345678',
      :roles => {
        :student => true,
        :exStudent => false,
        :faculty => false,
        :staff => false
      }
    }))
  end

  it "should find user with default name" do
    u = User::Api.new(@random_id)
    u.init
    u.preferred_name.should == @default_name
  end
  it "should override the default name" do
    u = User::Api.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = User::Api.new(@random_id)
    u.init
    u.preferred_name.should == "Herr Heyer"
  end
  it "should revert to the default name" do
    u = User::Api.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = User::Api.new(@random_id)
    u.update_attributes(preferred_name: "")
    u = User::Api.new(@random_id)
    u.init
    u.preferred_name.should == @default_name
  end
  it "should return a user data structure" do
    user_data = User::Api.new(@random_id).get_feed
    user_data[:preferred_name].should == @default_name
    user_data[:hasCanvasAccount].should_not be_nil
    user_data[:isCalendarOptedIn].should_not be_nil
    user_data[:sid].should == '1234567890'
    user_data[:campusSolutionsID].should == 'CC12345678'
    user_data[:isCampusSolutionsStudent].should be_truthy
    user_data[:showSisProfileUI].should be_truthy
  end
  context 'with a legacy student' do
    before do
      HubEdos::UserAttributes.stub(:new).and_return(
        double(
        get: {
          :person_name => @default_name,
          :campus_solutions_id => '12345678',    # note: 8-digit ID means legacy
          :roles => {
            :student => true,
            :exStudent => false,
            :faculty => false,
            :staff => false
          }
        }))
    end
    context 'with the fallback enabled' do
      before do
        allow(Settings.features).to receive(:cs_profile_visible_for_legacy_users).and_return(false)
      end
      it "should hide SIS profile for legacy students" do
        user_data = User::Api.new(@random_id).get_feed
        user_data[:isCampusSolutionsStudent].should be_falsey
        user_data[:showSisProfileUI].should be_falsey
      end
    end
    context 'with the fallback disabled' do
      before do
        allow(Settings.features).to receive(:cs_profile_visible_for_legacy_users).and_return(true)
      end
      it "should show SIS profile for legacy students" do
        user_data = User::Api.new(@random_id).get_feed
        user_data[:isCampusSolutionsStudent].should be_falsey
        user_data[:showSisProfileUI].should be_truthy
      end
    end
  end
  it "should return whether the user is registered with Canvas" do
    Canvas::Proxy.stub(:has_account?).and_return(true, false)
    user_data = User::Api.new(@random_id).get_feed
    user_data[:hasCanvasAccount].should be_truthy
    Rails.cache.clear
    user_data = User::Api.new(@random_id).get_feed
    user_data[:hasCanvasAccount].should be_falsey
  end
  it "should have a null first_login time for a new user" do
    user_data = User::Api.new(@random_id).get_feed
    user_data[:firstLoginAt].should be_nil
  end
  it "should properly register a call to record_first_login" do
    user_api = User::Api.new(@random_id)
    user_api.get_feed
    user_api.record_first_login
    updated_data = user_api.get_feed
    updated_data[:firstLoginAt].should_not be_nil
  end
  it "should delete a user and all his dependent parts" do
    user_api = User::Api.new @random_id
    user_api.record_first_login
    user_api.get_feed

    User::Oauth2Data.should_receive(:destroy_all)
    Notifications::Notification.should_receive(:destroy_all)
    Cache::UserCacheExpiry.should_receive(:notify)
    Calendar::User.should_receive(:delete_all)

    User::Api.delete @random_id

    User::Data.where(:uid => @random_id).should == []
  end

  it 'should say random student gets the academics tab', if: HubEdos::UserAttributes.test_data? do
    user_data = User::Api.new(@random_id).get_feed
    expect(user_data[:hasAcademicsTab]).to eq true
  end

  it 'should say a staff member with no academic history does not get the academics tab', if: HubEdos::UserAttributes.test_data? do
    allow(CampusOracle::UserAttributes).to receive(:new).and_return double(get_feed: {
      'person_name' => @default_name,
      :roles => {
        :student => false,
        :faculty => false,
        :staff => true
      }
    })
    allow(CampusOracle::UserCourses::HasInstructorHistory).to receive(:new).and_return double(has_instructor_history?: false)
    allow(HubEdos::UserAttributes).to receive(:new).and_return double(get: {
      person_name: @default_name,
      roles: {}
    })
    user_data = User::Api.new('904715').get_feed
    expect(user_data[:hasAcademicsTab]).to eq false
  end

  describe 'my finances tab' do
    let(:oracle_roles) do
      {
        :active   => { :student => true,  :exStudent => false, :faculty => false, :staff => false },
        :expired  => { :student => false, :exStudent => true,  :faculty => false, :staff => false },
        :non      => { :student => false, :exStudent => false, :faculty => false, :staff => true },
      }
    end
    let(:edo_roles) do
      {
        active: { student: true },
        expired: {},
        non: {},
      }
    end
    before do
      allow(CampusOracle::UserAttributes).to receive(:new).and_return double(get_feed: {
        roles: oracle_roles[test_roles]
      })
      allow(HubEdos::UserAttributes).to receive(:new).and_return double(get: {
        roles: edo_roles[test_roles]
      })
    end
    subject {User::Api.new(@random_id).get_feed[:hasFinancialsTab]}
    context 'an active student' do
      let(:test_roles) {:active}
      it {should be_truthy}
    end
    context 'a non-student' do
      let(:test_roles) {:non}
      it {should be_falsey}
    end
    context 'an ex-student' do
      let(:test_roles) {:expired}
      it {should be_truthy}
    end
  end

  describe 'My Toolbox tab' do
    context 'superuser' do
      before { User::Auth.new_or_update_superuser! @random_id }
      it 'should show My Toolbox tab' do
        user_api = User::Api.new(@random_id)
        expect(user_api.get_feed[:hasToolboxTab]).to be true
      end
    end
    context 'can_view_as' do
      before {
        user = User::Auth.new uid: @random_id
        user.is_viewer = true
        user.active = true
        user.save
      }
      subject { User::Api.new(@random_id).get_feed[:hasToolboxTab] }
      it { should be true }
    end
    context 'ordinary profiles' do
      let(:profiles) do
        {
          :student   => { :student => true,  :exStudent => false, :faculty => false, :staff => false },
          :faculty   => { :student => false, :exStudent => false, :faculty => true,  :staff => false },
          :staff     => { :student => false, :exStudent => false, :faculty => true,  :staff => true }
        }
      end
      before do
        allow(CampusOracle::UserAttributes).to receive(:new).and_return double get_feed: {
          roles: user_roles
        }
      end
      subject { User::Api.new(@random_id).get_feed[:hasToolboxTab] }
      context 'student' do
        let(:user_roles) { profiles[:student] }
        it { should be false }
      end
      context 'faculty' do
        let(:user_roles) { profiles[:faculty] }
        it { should be false }
      end
      context 'staff' do
        let(:user_roles) { profiles[:staff] }
        it { should be false }
      end
    end
  end

  it "should not explode when HubEdos returns empty feeds" do
    HubEdos::UserAttributes.stub(:new).and_return(double(get: {
    }))
    fake_instructor_proxy = CampusOracle::UserCourses::HasInstructorHistory.new({:fake => true})
    fake_instructor_proxy.stub(:has_instructor_history?).and_return(false)
    CampusOracle::UserCourses::HasInstructorHistory.stub(:new).and_return(fake_instructor_proxy)
    fake_student_proxy = CampusOracle::UserCourses::HasStudentHistory.new({:fake => true})
    fake_student_proxy.stub(:has_student_history?).and_return(false)
    CampusOracle::UserCourses::HasStudentHistory.stub(:new).and_return(fake_student_proxy)
    user_data = User::Api.new("904715").get_feed
    user_data[:hasAcademicsTab].should_not be_truthy
  end

  context 'HubEdos errors', if: CampusOracle::Queries.test_data? do
    let(:uid) { '1151855' }
    let(:feed) { User::Api.new(uid).get_feed }

    before do
      allow(HubEdos::UserAttributes).to receive(:new).and_return double(get: badly_behaved_edo_attributes)
    end

    let(:expected_values_from_campus_oracle) {
      {
        first_name: 'Eugene V',
        last_name: 'Debs',
        preferred_name: 'Eugene V Debs',
        fullName: 'Eugene V Debs',
        uid: '1151855',
        sid: '18551926',
        isCampusSolutionsStudent: false,
        roles: {
          student: true,
          registered: true,
          exStudent: false,
          faculty: false,
          staff: false,
          guest: false,
          concurrentEnrollmentStudent: false,
          expiredAccount: false
        }
      }
    }

    shared_examples 'handling bad behavior' do
      it 'should fall back to campus Oracle' do
        expect(feed).to include expected_values_from_campus_oracle
      end
    end

    context 'empty response' do
      let(:badly_behaved_edo_attributes) { {} }
      include_examples 'handling bad behavior'
    end

    context 'ID lookup errors' do
      let(:badly_behaved_edo_attributes) do
        {
          student_id: {
            body: 'An unknown server error occurred',
            statusCode: 503
          }
        }
      end
      include_examples 'handling bad behavior'
    end

    context 'name lookup errors' do
      let(:badly_behaved_edo_attributes) do
        {
          first_name: nil,
          last_name: nil,
          person_name: {
            body: 'An unknown server error occurred',
            statusCode: 503
          }
        }
      end
      include_examples 'handling bad behavior'
    end

    context 'role lookup errors' do
      let(:badly_behaved_edo_attributes) do
        {
          roles: {
            body: 'An unknown server error occurred',
            statusCode: 503
          }
        }
      end
      include_examples 'handling bad behavior'
    end
  end

  context "proper cache handling" do

    it "should update the last modified hash when content changes" do
      user_api = User::Api.new(@random_id)
      user_api.get_feed
      original_last_modified = User::Api.get_last_modified(@random_id)
      old_hash = original_last_modified[:hash]
      old_timestamp = original_last_modified[:timestamp]

      sleep 1

      user_api.preferred_name="New Name"
      user_api.save
      feed = user_api.get_feed
      new_last_modified = User::Api.get_last_modified(@random_id)
      new_last_modified[:hash].should_not == old_hash
      new_last_modified[:timestamp].should_not == old_timestamp
      new_last_modified[:timestamp][:epoch].should == feed[:lastModified][:timestamp][:epoch]
    end

    it "should not update the last modified hash when content hasn't changed" do
      user_api = User::Api.new(@random_id)
      user_api.get_feed
      original_last_modified = User::Api.get_last_modified(@random_id)

      sleep 1

      Cache::UserCacheExpiry.notify @random_id
      feed = user_api.get_feed
      unchanged_last_modified = User::Api.get_last_modified(@random_id)
      original_last_modified.should == unchanged_last_modified
      original_last_modified[:timestamp][:epoch].should == feed[:lastModified][:timestamp][:epoch]
    end

  end

  context "proper handling of superuser permissions" do
    before { User::Auth.new_or_update_superuser!(@random_id) }
    subject { User::Api.new(@random_id).get_feed }
    it "should pass the superuser status" do
      subject[:isSuperuser].should be_truthy
      subject[:isViewer].should be_truthy
      expect(subject[:hasToolboxTab]).to be true
    end
  end

  context "proper handling of viewer permissions" do
    before {
      user = User::Auth.new(uid: @random_id)
      user.is_viewer = true
      user.active = true
      user.save
    }
    subject { User::Api.new(@random_id).get_feed }
    it "should pass the viewer status" do
      subject[:isSuperuser].should be_falsey
      subject[:isViewer].should be_truthy
      expect(subject[:hasToolboxTab]).to be true
    end
  end

end
