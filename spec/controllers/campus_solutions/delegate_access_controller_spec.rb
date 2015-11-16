describe CampusSolutions::DelegateAccessController do

  let(:user_id) { '12346' }

  context 'user not authenticated' do
    it 'should not get students' do
      get :get_students,  {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    it 'should not permit post' do
      post :post, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end
  end

  context 'authenticated user' do
    before do
      session['user_id'] = user_id
      allow(User::Auth).to receive(:where).and_return [User::Auth.new(uid: user_id, is_superuser: false, active: true)]
    end

    it 'should get students list' do
      get :get_students
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed']['students']).to be_present
      json['feed']['students'].each do |student|
        expect(student['emplid']).to be_present
        expect(student['name']).to be_present
        expect(student['rolenames']).to be_present
      end
    end

    it 'should link a claimed student' do
      post :post, {
        proxyEmailAddress: 'squire.allworthy@gmail.com',
        securityKey: 'uy786XD'
      }
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed']['status']).to be_present
    end

    it 'should get terms and conditions' do
      get :get_terms_and_conditions
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed']['daAgreeToTerms']['termsAndConditions']).to include 'Excepteur sint occaecat'
    end
  end

end
