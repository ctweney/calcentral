describe User::SearchUsers do

  let(:fake_uid_proxy) { CalnetCrosswalk::ByUid.new }
  let(:fake_sid_proxy) { CalnetCrosswalk::BySid.new }
  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).and_return(fake_uid_proxy)
    allow(CalnetCrosswalk::BySid).to receive(:new).and_return(fake_sid_proxy)
  end
  it "should return valid record for valid uid" do
    allow(fake_uid_proxy).to receive(:lookup_student_id).and_return('24680')
    allow(fake_uid_proxy).to receive(:lookup_ldap_uid).and_return('13579')
    allow(fake_sid_proxy).to receive(:lookup_student_id).and_return(nil)
    allow(fake_sid_proxy).to receive(:lookup_ldap_uid).and_return(nil)
    model = User::SearchUsers.new({:id => '13579'})
    result = model.search_users
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 1
    expect(result[0]['student_id']).to eq "24680"
    expect(result[0]['ldap_uid']).to eq "13579"
  end

  it "should return valid record for valid sid" do
    allow(fake_uid_proxy).to receive(:lookup_student_id).and_return(nil)
    allow(fake_uid_proxy).to receive(:lookup_ldap_uid).and_return(nil)
    allow(fake_sid_proxy).to receive(:lookup_student_id).and_return('24680')
    allow(fake_sid_proxy).to receive(:lookup_ldap_uid).and_return('13579')
    model = User::SearchUsers.new({:id => '24680'})
    result = model.search_users
    expect(result).to be_an_instance_of Array
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 1
    expect(result[0]['student_id']).to eq "24680"
    expect(result[0]['ldap_uid']).to eq "13579"
  end

  it "returns no record for invalid id" do
    allow(fake_uid_proxy).to receive(:lookup_student_id).and_return(nil)
    allow(fake_uid_proxy).to receive(:lookup_ldap_uid).and_return(nil)
    allow(fake_sid_proxy).to receive(:lookup_student_id).and_return(nil)
    allow(fake_sid_proxy).to receive(:lookup_ldap_uid).and_return(nil)
    model = User::SearchUsers.new({:id => '12345'})
    result = model.search_users
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 0
  end

end
