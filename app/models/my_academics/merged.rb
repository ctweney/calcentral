module MyAcademics
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include MergedModel

    def self.providers
      # Provider ordering is significant! In particular, Semesters/Teaching must
      # be merged before course sites.
      [
        CollegeAndLevel,
        TransitionTerm,
        GpaUnits,
        Requirements,
        Regblocks,
        Semesters,
        Teaching,
        Exams,
        Telebears,
        CanvasSites
      ]
    end

    def get_feed_internal
      feed = {}
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        provider.new(@uid).merge feed
      end
      feed
    end
  end
end
