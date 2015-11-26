describe CampusSolutions::FinancialAidFundingSourcesTerm do

  let(:user_id) { '12345' }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the finaid feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:awards]).to be
      expect(subject[:feed][:awards][:semester]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::FinancialAidFundingSourcesTerm.new(user_id: user_id, fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::FinancialAidFundingSourcesTerm.new(user_id: user_id, fake: false, aid_year: 2016) }
    it_should_behave_like 'a proxy that gets data'
  end

end
