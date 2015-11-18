module CampusSolutions
  class MyDelegateAccess < UserSpecificModel

    include DelegatedAccessFeatureFlagged

    def get_feed
      CampusSolutions::DelegateStudents.new(user_id: @uid).get
    end

    def update(params = {})
      CampusSolutions::DelegateAccessCreate.new(user_id: @uid, params: params).get
    end

  end
end
