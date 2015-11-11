module CampusSolutions
  class MyDelegateAccess < UserSpecificModel

    def update(params = {})
      CampusSolutions::DelegateAccessCreate.new(user_id: @uid, params: params).get
    end

  end
end
