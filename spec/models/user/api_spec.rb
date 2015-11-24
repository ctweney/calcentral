describe User::Api do
  before(:each) do
    Settings.features.cs_profile = false
    @random_id = Time.now.to_f.to_s.gsub('.', '')
    @default_name = 'Joe Default'
    allow(CampusOracle::UserAttributes).to receive(:new).and_return double get_feed: {
      'person_name' => @default_name,
      'student_id' => 12345678,
      :roles => {
        :student => true,
        :exStudent => false,
        :faculty => false,
        :staff => false
      }
    }
  end

  after do
    Settings.features.cs_profile = true
  end

  it 'should find user with default name' do
    u = User::Api.new @random_id
    u.init
    expect(u.preferred_name).to eq @default_name
  end
  it 'should override the default name' do
    u = User::Api.new @random_id
    u.update_attributes preferred_name: 'Herr Heyer'
    u = User::Api.new @random_id
    u.init
    expect(u.preferred_name).to eq 'Herr Heyer'
  end
  it 'should revert to the default name' do
    u = User::Api.new @random_id
    u.update_attributes preferred_name: 'Herr Heyer'
    u = User::Api.new @random_id
    u.update_attributes preferred_name: ''
    u = User::Api.new @random_id
    u.init
    expect(u.preferred_name).to eq @default_name
  end
  it 'should return a user data structure' do
    user_data = User::Api.new(@random_id).get_feed
    expect(user_data[:preferred_name]).to eq @default_name
    expect(user_data[:hasCanvasAccount]).to_not be_nil
    expect(user_data[:isCalendarOptedIn]).to_not be_nil
    expect(user_data[:isCampusSolutionsStudent]).to be false
    expect(user_data[:showSisProfileUI]).to be false
    expect(user_data[:hasToolboxTab]).to be false
  end
  it 'should return whether the user is registered with Canvas' do
    expect(Canvas::Proxy).to receive(:has_account?).and_return(true, false)
    user_data = User::Api.new(@random_id).get_feed
    expect(user_data[:hasCanvasAccount]).to be true
    Rails.cache.clear
    user_data = User::Api.new(@random_id).get_feed
    expect(user_data[:hasCanvasAccount]).to be false
  end
  it 'should have a null first_login time for a new user' do
    user_data = User::Api.new(@random_id).get_feed
    expect(user_data[:firstLoginAt]).to be_nil
  end
  it 'should properly register a call to record_first_login' do
    user_api = User::Api.new @random_id
    user_api.get_feed
    user_api.record_first_login
    updated_data = user_api.get_feed
    expect(updated_data[:firstLoginAt]).to_not be_nil
  end
  it 'should delete a user and all his dependent parts' do
    user_api = User::Api.new @random_id
    user_api.record_first_login
    user_api.get_feed

    expect(User::Oauth2Data).to receive :destroy_all
    expect(Notifications::Notification).to receive :destroy_all
    expect(Cache::UserCacheExpiry).to receive :notify
    expect(Calendar::User).to receive :delete_all

    User::Api.delete @random_id

    expect(User::Data.where :uid => @random_id).to eq []
  end

  it 'should say random student gets the academics tab', if: CampusOracle::Queries.test_data? do
    user_data = User::Api.new(@random_id).get_feed
    expect(user_data[:hasAcademicsTab]).to be true
  end

  it 'should say a staff member with no academic history does not get the academics tab', if: CampusOracle::Queries.test_data? do
    allow(CampusOracle::UserAttributes).to receive(:new).and_return double get_feed: {
      'person_name' => @default_name,
      :roles => {
        :student => false,
        :faculty => false,
        :staff => true
      }
    }
    fake_instructor_proxy = CampusOracle::UserCourses::HasInstructorHistory.new :fake => true
    expect(fake_instructor_proxy).to receive(:has_instructor_history?).and_return false
    expect(CampusOracle::UserCourses::HasInstructorHistory).to receive(:new).and_return fake_instructor_proxy
    fake_student_proxy = CampusOracle::UserCourses::HasStudentHistory.new :fake => true
    expect(fake_student_proxy).to receive(:has_student_history?).and_return false
    expect(CampusOracle::UserCourses::HasStudentHistory).to receive(:new).and_return fake_student_proxy
    user_data = User::Api.new('904715').get_feed
  end

  describe 'My Finances tab' do
    let(:student_profiles) do
      {
        :active   => { :student => true,  :exStudent => false, :faculty => false, :staff => false },
        :expired  => { :student => false, :exStudent => true,  :faculty => false, :staff => false },
        :non      => { :student => false, :exStudent => false, :faculty => false, :staff => true }
      }
    end
    before do
      allow(CampusOracle::UserAttributes).to receive(:new).and_return double get_feed: { roles: user_roles }
    end
    subject { User::Api.new(@random_id).get_feed[:hasFinancialsTab] }
    context 'active student' do
      let(:user_roles) { student_profiles[:active] }
      it { should be true }
    end
    context 'non-student' do
      let(:user_roles) { student_profiles[:non] }
      it { should be false }
    end
    context 'ex-student' do
      let(:user_roles) { student_profiles[:expired] }
      it { should be true }
    end
  end

  describe 'My Toolbox tab' do
    context 'superuser' do
      before { User::Auth.new_or_update_superuser! @random_id }
      it 'should show My Toolbox tab' do
        user_api = User::Api.new @random_id
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

  it 'should not explode when CampusOracle returns empty feeds' do
    expect(CampusOracle::UserAttributes).to receive(:new).and_return double(get_feed: {})
    fake_instructor_proxy = CampusOracle::UserCourses::HasInstructorHistory.new :fake => true
    expect(fake_instructor_proxy).to receive(:has_instructor_history?).and_return false
    expect(CampusOracle::UserCourses::HasInstructorHistory).to receive(:new).and_return fake_instructor_proxy
    fake_student_proxy = CampusOracle::UserCourses::HasStudentHistory.new :fake => true
    expect(fake_student_proxy).to receive(:has_student_history?).and_return false
    expect(CampusOracle::UserCourses::HasStudentHistory).to receive(:new).and_return fake_student_proxy
    user_data = User::Api.new('904715').get_feed
  end

  context 'proper cache handling' do

    it 'should update the last modified hash when content changes' do
      user_api = User::Api.new @random_id
      user_api.get_feed
      original_last_modified = User::Api.get_last_modified @random_id
      old_hash = original_last_modified[:hash]
      old_timestamp = original_last_modified[:timestamp]

      sleep 1

      user_api.preferred_name = 'New Name'
      user_api.save
      feed = user_api.get_feed
      new_last_modified = User::Api.get_last_modified @random_id
      expect(new_last_modified[:hash]).to_not eq old_hash
      expect(new_last_modified[:timestamp]).to_not eq old_timestamp
      expect(new_last_modified[:timestamp][:epoch]).to eq feed[:lastModified][:timestamp][:epoch]
    end

    it 'should not update the last modified hash when content has not changed' do
      user_api = User::Api.new @random_id
      user_api.get_feed
      original_last_modified = User::Api.get_last_modified @random_id

      sleep 1

      Cache::UserCacheExpiry.notify @random_id
      feed = user_api.get_feed
      unchanged_last_modified = User::Api.get_last_modified @random_id
      expect(original_last_modified).to eq unchanged_last_modified
      expect(original_last_modified[:timestamp][:epoch]).to eq feed[:lastModified][:timestamp][:epoch]
    end

  end

  context 'proper handling of superuser permissions' do
    before { User::Auth.new_or_update_superuser! @random_id }
    subject { User::Api.new(@random_id).get_feed }
    it 'should pass the superuser status' do
      expect(subject[:isSuperuser]).to be true
      expect(subject[:isViewer]).to be true
      expect(subject[:hasToolboxTab]).to be true
    end
  end

  context 'proper handling of viewer permissions' do
    before {
      user = User::Auth.new uid: @random_id
      user.is_viewer = true
      user.active = true
      user.save
    }
    subject { User::Api.new(@random_id).get_feed }
    it 'should pass the viewer status' do
      expect(subject[:isSuperuser]).to be false
      expect(subject[:isViewer]).to be true
      expect(subject[:hasToolboxTab]).to be true
    end
  end

end
