module CampusSolutions
  class DelegateAccessController < CampusSolutionsController

    def get_students
      render json: CampusSolutions::MyDelegateAccess.from_session(session).get_feed
    end

    def get_delegate_management_url
      json_passthrough CampusSolutions::DelegateManagementURL
    end

    def get_terms_and_conditions
      # TODO: Remove fake:true when CS API is implemented
      json_passthrough(CampusSolutions::DelegateTermsAndConditions, fake: true)
    end

    def post
      post_passthrough CampusSolutions::MyDelegateAccess
    end

  end
end
