describe HubEdos::Contacts do

  context 'mock proxy' do
    let(:proxy) { HubEdos::Contacts.new(fake: true, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['identifiers'][0]['type']).to be
      expect(subject[:feed]['student']['addresses'][0]['state']).to eq 'CA'
      expect(subject[:feed]['student']['addresses'][0]['postal']).to eq '94720'
      expect(subject[:feed]['student']['addresses'][0]['country']).to eq 'USA'
      expect(subject[:feed]['student']['addresses'][0]['formattedAddress']).to eq "2111 BANCROFT WAY  #550\nBERKELEY, California 94720"
      expect(subject[:feed]['student']['phones'].length).to eq 1
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { HubEdos::Contacts.new(fake: false, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['identifiers'][0]['type']).to be
    end

  end
end
