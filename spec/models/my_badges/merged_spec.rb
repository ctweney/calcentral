describe 'MyBadges::Merged' do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_drive_list = GoogleApps::DriveList.new(:fake => true)
    @fake_events_list = GoogleApps::EventsRecentItems.new(:fake => true)
    @fake_mail_list = GoogleApps::MailList.new(:fake => true)
    @real_drive_list = GoogleApps::DriveList.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
  end

  let(:badges) { MyBadges::Merged.new @user_id }

  context 'fake authenticated connection' do
    before do
      allow(GoogleApps::Proxy).to receive(:access_granted?).and_return true
      allow(GoogleApps::DriveList).to receive(:new).and_return @fake_drive_list
      allow(GoogleApps::EventsRecentItems).to receive(:new).and_return @fake_events_list
      allow(GoogleApps::MailList).to receive(:new).and_return @fake_mail_list
      allow(User::Oauth2Data).to receive(:get_google_email).and_return 'tammi.chang.clc@gmail.com'
    end

    it 'should return fake calendar items' do
      feed = badges.get_feed
      expect(feed[:badges]['bcal'][:count]).to eq 6
      expect(feed[:badges]['bcal'][:items]).to have(6).items
      expect(feed[:badges]['bcal'][:items].select { |entry| entry[:allDayEvent] }).to have(1).items
      expect(feed[:badges]['bcal'][:items].select { |entry| entry[:changeState] == 'new' }).to have(1).items
      expect(feed[:badges]['bcal'][:items].select { |entry| entry[:changeState] == 'created' }).to have(1).items
    end

    it 'should be able to filter out entries older than one month' do
      filtered_feed = badges.get_feed
      expect(filtered_feed[:badges]['bdrive'][:count]).to eq 4
      expect(filtered_feed[:badges]['bdrive'][:items]).to have(4).items

      badges.expire_cache
      MyBadges::GoogleDrive.expire @user_id
      allow_any_instance_of(MyBadges::GoogleDrive).to receive(:is_recent_message?).and_return true
      unfiltered_feed = MyBadges::Merged.new(@user_id).get_feed
      expect(unfiltered_feed[:badges]['bdrive'][:count]).to eq 10
      expect(unfiltered_feed[:badges]['bdrive'][:items]).to have(10).items
    end

    it 'should be able to ignore entries with malformed fields' do
      allow_any_instance_of(MyBadges::GoogleDrive).to receive(:is_recent_message?).and_raise(ArgumentError, 'foo')
      allow_any_instance_of(MyBadges::GoogleCalendar).to receive(:verify_and_format_date).and_raise(ArgumentError, 'foo')
      suppress_rails_logging do
        filtered_feed = badges.get_feed
        expect(filtered_feed[:badges]['bcal'][:count]).to eq 0
        expect(filtered_feed[:badges]['bdrive'][:count]).to eq 0
        expect(filtered_feed[:badges]['bmail'][:count]).to be > 0
      end
    end

    it 'should handle utter failure from a particular source' do
      allow_any_instance_of(MyBadges::GoogleDrive).to receive(:fetch_counts).and_raise NoMethodError
      allow(Rails.logger).to receive(:error).with anything
      expect(Rails.logger).to receive(:error).with /Failed to merge MyBadges::GoogleDrive for UID #{@user_id}: NoMethodError/
      feed = badges.get_feed
      expect(feed[:badges]['bcal'][:count]).to be > 0
      expect(feed[:badges]['bmail'][:count]).to be > 0
      expect(feed[:badges]).not_to include 'bdrive'
      expect(feed[:errors]).to eq ['MyBadges::GoogleDrive']
    end

    it 'should contain some of the same common item-keys across the different badge endpoints' do
      badges.get_feed[:badges].each do |source_key, source_value|
        expect(source_value[:count]).to be_present
        expect(source_value[:items]).to be_kind_of Enumerable
        source_value[:items].each do |feed_items|
          if %w(bcal bdrive).include? source_key
            expect(feed_items[:changeState]).to be_present
          end
          if source_key == 'bcal'
            %w(startTime endTime).each do |required_key|
              expect(feed_items[required_key.to_sym]).to be_present
            end
            if feed_items[:changeState] == 'new'
              expect(feed_items[:editor]).to be_present
            end
          else
            expect(feed_items[:editor]).to be_present
          end
          %w(title modifiedTime link).each do |required_key|
            expect(feed_items[required_key.to_sym]).to be_present
          end
        end
      end
    end

    it 'should return all zeros on non-responsive Google' do
      allow_any_instance_of(Google::APIClient).to receive(:execute).and_raise StandardError
      feed = badges.get_feed
      expect(feed[:badges]).to_not be_empty
      expect(feed[:badges].values).to all eq(items: [], count: 0)
    end
  end

  it 'should return no badges when not authenticated' do
    allow(GoogleApps::Proxy).to receive(:access_granted?).and_return(false)
    badges = MyBadges::Merged.new(@user_id).get_feed[:badges]
    expect(badges).to be_blank
  end

  context 'css classes for bdrive icons' do
    let (:proxy) { MyBadges::GoogleDrive.new(@user_id) }
    let (:icon_class_result) { proxy.send(:process_icon, image_url) }

    context 'when icon is an expected png file' do
      let (:image_url) { 'https://ssl.gstatic.com/docs/doclist/images/icon_11_document_list.png' }
      it 'should return the file basename' do
        expect(icon_class_result).to eq 'icon_11_document_list'
      end
    end

    context 'when icon is an unexpected png file' do
      let (:image_url) { 'https://ssl.gstatic.com/docs/doclist/images/icon_11_cuneiform_list.png' }
      it 'should return nothing' do
        expect(icon_class_result).to be_blank
      end
    end

    context 'when icon is not a png file' do
      let (:image_url) { 'http://www.google.com/lol_cat.gif' }
      it 'should return nothing' do
        expect(icon_class_result).to be_blank
      end
    end
  end
end
