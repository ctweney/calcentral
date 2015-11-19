module CampusSolutions
  class MyChecklist < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include CampusSolutions::SirFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled
      CampusSolutions::Checklist.new({user_id: @uid}).get
    end

  end
end
