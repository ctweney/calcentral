module MyGroups
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include MergedModel

    def self.providers
      [
        MyGroups::Callink,
        MyGroups::Canvas
      ]
    end

    def get_feed_internal
      feed = {
        groups: []
      }
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        feed[:groups].concat provider.new(@uid).fetch
      end
      feed[:groups].sort! { |x, y| x[:name].casecmp y[:name] }
      feed
    end

  end
end
