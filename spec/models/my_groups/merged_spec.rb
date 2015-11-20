describe MyGroups::Merged do
  let(:feed) { MyGroups::Merged.new(uid).get_feed }

  context 'when not authenticated' do
    let(:uid) { nil }
    it { expect(feed[:groups]).to be_empty }
  end

  context 'when multiple groups returned' do
    let(:uid) { rand(99999).to_s }
    before do
      allow(MyGroups::Canvas).to receive(:new).with(uid).and_return double(fetch: [
        {name: 'qgroup', id: rand(9999).to_s, emitter: 'bCourses'}
      ])
      allow(MyGroups::Callink).to receive(:new).with(uid).and_return double(fetch: [
        {name: 'young bears', id: rand(9999).to_s, emitter: 'CalLink'},
        {name: 'Old Bears', id: rand(9999).to_s, emitter: 'CalLink'}
      ])
    end

    it 'sorts alphabetically' do
      expect(feed[:groups].map { |group| group[:name] }).to eq ['Old Bears', 'qgroup', 'young bears']
    end

    context 'when a provider misbehaves' do
      let(:uid) { rand(99999).to_s }
      before { allow(MyGroups::Canvas).to receive(:new).with(uid).and_raise NoMethodError }

      it 'returns what data it can and reports the error' do
        expect(Rails.logger).to receive(:error).with /Failed to merge MyGroups::Canvas for UID #{uid}: NoMethodError/
        expect(feed[:groups].map { |group| group[:name] }).to eq ['Old Bears', 'young bears']
        expect(feed[:errors]).to eq ['MyGroups::Canvas']
      end
    end
  end
end
