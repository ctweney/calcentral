describe 'MyAcademics::CollegeAndLevel' do

  context 'known test users' do
    let(:uid) { '61889' }
    let(:feed) { {} }

    before do
      profile_proxy = Bearfacts::Profile.new(user_id: uid, fake: true)
      allow(Bearfacts::Profile).to receive(:new).and_return profile_proxy
      MyAcademics::CollegeAndLevel.new(uid).merge feed
      expect(feed).not_to be_empty
    end

    let(:colleges) { feed[:collegeAndLevel][:colleges] }

    it 'should get properly formatted data from fake Bearfacts' do
      expect(colleges).to have(1).items
      expect(colleges.first).to include(
        college: 'College of Letters & Science',
        major: 'Statistics'
      )
      expect(feed[:collegeAndLevel]).to include(
        standing: 'Undergraduate',
        termName: 'Fall 2015'
      )
    end

    context 'enrollment in multiple colleges' do
      let(:uid) { '300940' }
      it 'should return multiple colleges and majors' do
        expect(colleges).to have(2).items
        expect(colleges[0]).to include(
          college: 'College of Natural Resources',
          major: 'Conservation And Resource Studies'
        )
        expect(colleges[1]).to include(
          college: 'College of Environmental Design',
          major: 'Landscape Architecture'
        )
      end
    end

    context 'a concurrent enrollment triple major' do
      let(:uid) { '212379' }
      it 'should return even more colleges and majors' do
        expect(colleges).to have(3).items
        expect(colleges[0]).to include(
          college: 'College of Chemistry',
          major: 'Chemistry'
        )
        expect(colleges[1]).to include(
          college: 'College of Letters & Science',
          major: 'Applied Mathematics'
        )
        expect(colleges[2]).to include(
          college: '',
          major: 'Physics'
        )
      end
    end

    context 'a double law major' do
      let(:uid) { '212381' }
      it 'should return the law in all its aspects' do
        expect(colleges).to have(2).items
        expect(colleges[0]).to include(
          college: 'School of Law',
          major: 'Jurisprudence And Social Policy'
        )
        expect(colleges[1]).to include(
          college: '',
          major: 'Law'
        )
      end
    end
  end

  context 'failing bearfacts proxy' do
    let(:uid) {'212381'}
    let(:feed) {{}}
    before(:each) do
      stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      Bearfacts::Profile.new({user_id: uid, fake: false})
    end
    it 'indicates a server failure' do
      MyAcademics::CollegeAndLevel.new(uid).merge(feed)
      expect(feed[:collegeAndLevel][:errored]).to be_truthy
    end
 end

  context 'when Bearfacts feed is incomplete' do
    let(:uid) {rand(999999)}
    let(:feed) {{}}
    before do
      allow(Bearfacts::Profile).to receive(:new).with(user_id: uid).and_return(double(get: {
        feed: FeedWrapper.new(MultiXml.parse(xml_body))
      }))
      MyAcademics::CollegeAndLevel.new(uid).merge(feed)
    end

    context 'when Bearfacts student profile lacks key data' do
      let(:xml_body) {
        '<studentProfile xmlns="urn:berkeley.edu/babl" termName="Spring" termYear="2014" asOfDate="May 27, 2014 12:00 AM"><studentType>STUDENT</studentType><noProfileDataFlag>false</noProfileDataFlag><studentGeneralProfile><studentName><firstName>OWPRQTOPEW</firstName><lastName>SEBIRTFEIWB</lastName></studentName></studentGeneralProfile></studentProfile>'
      }
      it 'reports an empty feed for the Bearfacts-provided term' do
        expect(feed[:collegeAndLevel]).to include(
          empty: true,
          termName: 'Spring 2014'
        )
        expect(feed[:collegeAndLevel]).not_to include :errored
      end
    end

    context 'when Bearfacts student profile is completely empty' do
      let(:xml_body) { nil }
      it 'reports an empty feed for the CalCentral current term' do
        expect(feed[:collegeAndLevel]).to include(
          empty: true,
          termName: Berkeley::Terms.fetch.current.to_english
        )
        expect(feed[:collegeAndLevel]).not_to include :errored
      end
    end
  end

end
