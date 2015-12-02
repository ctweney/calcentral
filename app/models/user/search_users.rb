module User
  class SearchUsers
    extend Cache::Cacheable

    def initialize(options={})
      @id = options[:id]
    end

    def search_users
      self.class.fetch_from_cache "#{@id}" do
        if Settings.features.cs_profile
          results = []
          [CalnetCrosswalk::ByUid, CalnetCrosswalk::BySid].each do |proxy_class|
            proxy = proxy_class.new(user_id: @id)
            sid = proxy.lookup_student_id
            uid = proxy.lookup_ldap_uid
            if sid.present? || uid.present?
              results << {
                'ldap_uid' => uid,
                'student_id' => sid
              }
            end
          end
          results
        else
          users_uid = User::SearchUsersByUid.new(id: @id).search_users_by_uid
          users_sid = User::SearchUsersBySid.new(id: @id).search_users_by_sid
          users_uid + users_sid
        end
      end
    end

  end
end
