module MyAcademics
  class FilteredForDelegate < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include MergedModel

    def self.providers
      [
        CollegeAndLevel,
        TransitionTerm,
        GpaUnits,
        Semesters
      ]
    end

    def get_feed_as_json(force_cache_write=false)
      if show_grades?
        super(force_cache_write)
      else
        feed = get_feed(force_cache_write)
        filter_grades(feed).to_json
      end
    end

    def get_feed_internal
      feed = {
        filteredForDelegate: true
      }
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        provider.new(@uid).merge feed
      end
      feed
    end

    private

    def filter_grades(feed)
      feed[:semesters].each do |semester|
        semester[:classes].each do |course|
          [:sections, :transcript].each do |key|
            course[key].each { |section| section.delete :grade } if course[key]
          end
        end
      end
      feed[:gpaUnits].delete :cumulativeGpa
      feed
    end

    def show_grades?
      delegate_permissions.include? 'View grades'
    end
  end
end
