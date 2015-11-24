describe MyAcademicsController do

  it_should_behave_like 'a user authenticated api endpoint' do
    let(:make_request) { get :get_feed }
  end

  it 'should get a non-empty feed for an authenticated (but fake) user' do
    session['user_id'] = '0'
    get :get_feed
    json_response = JSON.parse(response.body)
    expect(json_response['regblocks']['noStudentId']).to eq true
  end

  context 'fake campus data', if: CampusOracle::Connection.test_data? do
    let(:uid) { '61889' }
    before do
      fake_classes = Bearfacts::Proxy.subclasses + [ Regstatus::Proxy ]
      fake_classes.each do |klass|
        allow(klass).to receive(:new).and_return klass.new(user_id: uid, fake: true)
      end
      session['user_id'] = uid
    end

    it 'should get a feed full of content' do
      get :get_feed
      json_response = JSON.parse(response.body)
      expect(json_response['feedName']).to eq 'MyAcademics::Merged'
      expect(json_response['examSchedule']).to have(3).items
      expect(json_response['gpaUnits']).to include 'cumulativeGpa'
      expect(json_response['otherSiteMemberships']).to be_present
      expect(json_response['regblocks']).to be_present
      expect(json_response['requirements']).to be_present
      expect(json_response['semesters']).to have(24).items
      expect(json_response['semesters'][0]['slug']).to be_present
      expect(json_response['semesters'][1]['classes'][0]['transcript'][0]['grade']).to be_present
      expect(json_response['transitionTerm']).to be_present
    end

    context 'delegate view' do
      before { allow_any_instance_of(AuthenticationState).to receive(:authenticated_as_delegate?).and_return true }

      it 'should get a filtered feed' do
        get :get_feed
        json_response = JSON.parse(response.body)
        expect(json_response['feedName']).to eq 'MyAcademics::FilteredForDelegate'
        expect(json_response).not_to include 'examSchedule'
        expect(json_response['gpaUnits']).not_to include 'cumulativeGpa'
        expect(json_response).not_to include 'otherSiteMemberships'
        expect(json_response).not_to include 'regblocks'
        expect(json_response).not_to include 'requirements'
        expect(json_response['semesters']).to have(24).items
        expect(json_response['semesters'][0]).not_to include 'slug'
        expect(json_response['semesters'][1]['classes'][0]['transcript'][0]).not_to include 'grade'
        expect(json_response['transitionTerm']).to be_present
      end
    end
  end
end
