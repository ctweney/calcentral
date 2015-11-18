describe CampusSolutions::DelegateStudents do
  let(:user_id) { '12347' }
  let(:proxy) { CampusSolutions::DelegateStudents.new(fake: true, user_id: user_id) }
  subject { proxy.get }

  it_should_behave_like 'a simple proxy that returns errors'
  it_should_behave_like 'a proxy that got data successfully'
  it_should_behave_like 'a proxy that properly observes the delegated access feature flag'

  it 'returns expected mock data' do
    students = subject[:feed][:students]
    expect(students).to have(2).items
    expect(students.find { |s| s[:name] == 'Tom Tulliver' }[:emplid]).to eq '16777216'
    expect(students.find { |s| s[:name] == 'Tom Tulliver' }[:rolenames]).to eq ['UC DA InPerson Call Access']
    expect(students.find { |s| s[:name] == 'Maggie Tulliver' }[:rolenames]).to match_array ['UC DA Financial View', 'UC DA InPerson Call Access']
  end
end
