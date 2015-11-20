module MyActivities
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include MergedModel

    def self.providers
      [
        MyActivities::NotificationActivities,
        MyActivities::RegBlocks,
        MyActivities::Webcasts,
        MyActivities::CampusSolutionsMessages,
        MyActivities::CanvasActivities
      ]
    end

    def self.cutoff_date
      @cutoff_date ||= (Settings.terms.fake_now || Time.zone.today.in_time_zone).to_datetime.advance(days: -10).to_time.to_i
    end

    def get_feed_internal
      feed = {
        activities: [],
        archiveUrl: cs_dashboard_url
      }

      # Note that some providers require MyActivities::DashboardSites, which in turn has a direct dependency on
      # MyClasses and MyGroups.
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        if provider.respond_to? :append_with_dashboard_sites!
          provider.append_with_dashboard_sites!(@uid, feed[:activities], dashboard_sites)
        else
          provider.append!(@uid, feed[:activities])
        end
      end

      feed
    end

    def cs_dashboard_url
      cs_dashboard_url_feed = CampusSolutions::DashboardUrl.new.get
      cs_dashboard_url_feed && cs_dashboard_url_feed[:feed] && cs_dashboard_url_feed[:feed][:url]
    end

    def dashboard_sites
      MyActivities::DashboardSites.fetch(@uid, @options)
    end

  end
end
