module CampusSolutions
  class DelegateAccessController < CampusSolutionsController

    def get
      # TODO: Remove fake:true when CS API is implemented
      json_passthrough(CampusSolutions::DelegateTermsAndConditions, fake: true)
    end

    def post
      post_passthrough CampusSolutions::MyDelegateAccess
    end

  end
end
