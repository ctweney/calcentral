module CampusSolutions
  module PersonDataUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      proxy.get
      PersonDataExpiry.expire_on_profile_change @uid
    end
  end
end
