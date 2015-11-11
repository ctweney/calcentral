describe CampusSolutions::DelegateAccessCreate do
  let(:user_id) { '12346' }
  let(:params) { {
    bogus: 1,
    invalid: 2,
    proxyEmailAddress: 'squire.allworthy@gmail.com',
    securityKey: 'uy786XD'
  } }
  let(:proxy) { CampusSolutions::DelegateAccessCreate.new(fake: true, user_id: user_id, params: params) }

  context 'building a request' do
    let(:post) { proxy.construct_cs_post params }
    let(:post_body) { MultiXml.parse(post)['DA_VAL_CREATE_REQ'] }

    it 'should populate Campus Solutions params without exploding on bogus fields' do
      expect(post_body).to eq({
        'SCC_DA_PRXY_OPRID' => user_id,
        'SCC_DA_PRXY_EMAIL' => 'squire.allworthy@gmail.com',
        'SCC_DA_SECURTY_KEY' => 'uy786XD'
      })
    end
  end

  context 'performing a post' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_should_behave_like 'a proxy that got data successfully'
  end
end
