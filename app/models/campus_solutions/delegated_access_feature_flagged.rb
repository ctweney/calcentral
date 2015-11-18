module CampusSolutions
  module DelegatedAccessFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_delegated_access
    end
  end
end
