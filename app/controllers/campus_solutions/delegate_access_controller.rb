module CampusSolutions
  class DelegateAccessController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyDelegateAccess
    end

  end
end
