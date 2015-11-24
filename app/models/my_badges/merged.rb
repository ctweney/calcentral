module MyBadges
  class Merged < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include Cache::FilteredViewAsFeed
    include MergedModel

    def self.providers
      {
        'bcal' => GoogleCalendar,
        'bdrive' => GoogleDrive,
        'bmail' => GoogleMail
      }
    end

    def initialize(uid, options={})
      super(uid, options)
      @now_time = Time.zone.now
    end

    def provider_class_name(provider)
      provider[1].to_s
    end

    def get_feed_internal
      feed = {
        alert: get_latest_alert,
        badges: {},
        studentInfo: StudentInfo.new(@uid).get
      }
      merge_google_badges feed
      logger.debug "#{self.class.name} get_feed is #{feed.inspect}"
      feed
    end

    def filter_for_view_as(feed)
      filtered_badges = {}
      self.class.providers.each_key do |key|
        filtered_badges[key] = {
          count: 0,
          items: []
        }
      end
      feed[:badges] = filtered_badges
      feed
    end

    def merge_google_badges(feed)
      if GoogleApps::Proxy.access_granted?(@uid)
        handling_provider_exceptions(feed, self.class.providers) do |provider_key, provider_value|
          feed[:badges][provider_key] = provider_value.new(@uid).fetch_counts
        end
      end
    end

    def get_latest_alert
      if Settings.features.service_alerts_rss
        EtsBlog::ServiceAlerts.new.get_latest
      else
        EtsBlog::Alerts.new.get_latest
      end
    end

  end
end
