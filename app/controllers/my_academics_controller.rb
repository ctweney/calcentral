class MyAcademicsController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    if current_user.authenticated_as_delegate?
      render json: MyAcademics::FilteredForDelegate.from_session(session).get_feed_as_json
    else
      render json: MyAcademics::Merged.from_session(session).get_feed_as_json
    end
  end

end
