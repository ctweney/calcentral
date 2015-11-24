describe MyAcademics::FilteredForDelegate do
  let(:provider_classes) do
    [
      MyAcademics::CollegeAndLevel,
      MyAcademics::TransitionTerm,
      MyAcademics::GpaUnits,
      MyAcademics::Semesters
    ]
  end

  let(:uid) { '61889' }
  before do
    fake_classes = Bearfacts::Proxy.subclasses + [ Regstatus::Proxy ]
    fake_classes.each do |klass|
      allow(klass).to receive(:new).and_return klass.new(user_id: uid, fake: true)
    end
    allow_any_instance_of(AuthenticationState).to receive(:delegate_permissions).and_return fake_delegate_permissions
  end
  let(:feed) { JSON.parse described_class.new(uid).get_feed_as_json }

  shared_examples 'filtered feed' do
    it 'should include expected components' do
      expect(feed['collegeAndLevel']).to be_present
      expect(feed['transitionTerm']).to be_present
      expect(feed['semesters']).to be_present
    end
  end

  context 'when delegate permissions include grades', if: CampusOracle::Connection.test_data?  do
    let(:fake_delegate_permissions) { ['View grades', 'View enrollments'] }
    include_examples 'filtered feed'

    it 'should return grades' do
      expect(feed['gpaUnits']).to include 'cumulativeGpa'
      feed['semesters'].each do |semester|
        semester['classes'].each do |course|
          expect(course['transcript'].first).to include 'grade'
        end
      end
    end
  end

  context 'when delegate permissions do not include grades', if: CampusOracle::Connection.test_data? do
    let(:fake_delegate_permissions) { ['View enrollments', 'View finances'] }
    include_examples 'filtered feed'

    it 'should not return grades' do
      expect(feed['gpaUnits']).not_to include 'cumulativeGpa'
      feed['semesters'].each do |semester|
        semester['classes'].each do |course|
          expect(course['transcript'].first).not_to include 'grade'
        end
      end
    end
  end
end
