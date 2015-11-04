module CampusSolutions
  class FinancialAidFundingSourcesController < CampusSolutionsController

    def get
      model = CampusSolutions::MyFinancialAidFundingSources.from_session(session)
      model.aid_year = params['aid_year']
      render json: model.get_feed_as_json
    end

  end
end
