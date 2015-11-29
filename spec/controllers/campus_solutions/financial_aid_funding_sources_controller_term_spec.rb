describe CampusSolutions::FinancialAidFundingSourcesTermController do

  let(:user_id) { '12345' }

  context 'financial data feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_key) { 'message' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed, {:aid_year => '2016', :format => 'json'}
        json = JSON.parse(response.body)
        expect(json['feed']['awards']).to be
        expect(json['feed']['message']).to eq 'Financial aid awards are offered to meet your need up to your student budget (estimated cost of attendance).'
      end
    end
  end

end
