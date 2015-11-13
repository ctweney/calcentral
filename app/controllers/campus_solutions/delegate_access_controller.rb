module CampusSolutions
  class DelegateAccessController < CampusSolutionsController

    def get_terms_and_conditions
      # TODO: Remove fake:true when CS API is implemented
      json_passthrough(CampusSolutions::DelegateTermsAndConditions, fake: true)
    end

    def post
      post_passthrough CampusSolutions::MyDelegateAccess
    end

  end
end
