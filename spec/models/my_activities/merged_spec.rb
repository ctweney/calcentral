describe MyActivities::Merged do
  let(:user_id) { rand(99999).to_s }
  let(:activities) { described_class.new(user_id) }

  let(:array_inserter) do
    class ArrayInserter
      def self.append!(uid, activities)
        activities << ["#{self.name} #{uid}"]
      end
    end
    ArrayInserter
  end

  let(:hash_inserter) do
    class HashInserter
      def self.append_with_dashboard_sites!(uid, activities, dashboard_sites)
        activities << Hash[*[self.name, uid]]
      end
    end
    HashInserter
  end

  before do
    allow(MyActivities::DashboardSites).to receive(:fetch).and_return []
    allow(MyActivities::Merged).to receive(:providers).and_return providers
  end

  subject { activities.get_feed }

  context 'when providers are well behaved' do
    let(:providers) { [array_inserter, hash_inserter] }

    it 'should return a merged result' do
      expect { subject }.to_not raise_exception
      expect(subject[:activities][0]).to eq ["ArrayInserter #{user_id}"]
      expect(subject[:activities][1]).to eq({'HashInserter' => user_id})
      expect(subject[:errors]).to be_blank
    end
  end

  context 'when a provider misbehaves' do
    let(:providers) { [array_inserter, NilClass, hash_inserter] }

    it 'should return the better-behaved providers and report error' do
      expect(Rails.logger).to receive(:error).with /Failed to merge NilClass for UID #{user_id}: NoMethodError/
      expect { subject }.to_not raise_exception
      expect(subject[:activities][0]).to eq ["ArrayInserter #{user_id}"]
      expect(subject[:activities][1]).to eq({'HashInserter' => user_id})
      expect(subject[:errors]).to eq ['NilClass']
    end
  end

end
